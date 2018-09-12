/*
 * Implements a subset of MIPs from
 * https://www.student.cs.uwaterloo.ca/~cs241/mips/mipsref.pdf
 */

// From stdlib
import io
import system
import string
import list
import data

// Utilities
let toBinString => (num, numOfDigits) {
	let res = "";
	for num > 0 {
		res = (num % 2) + res;
		num \= 2;
	}
	if res.size > numOfDigits {
		"Overflow! " + res + " cannot fit in " + numOfDigits + " binary digits!";
		ret "0" * numOfDigits;
	}
	for res.size < numOfDigits {
		res = "0" + res;
	}
	ret res;
};

let contains => (string, char) {
	for c in string
		if c == char
			ret true
	ret false
};

let matcher = [];
let gen => (name, format) {
	// Remove spaces from format:
	format = (format / " ") % "";
	// Make it a list of common character: 00aabbccc0 -> [00, aa, bb, ccc, 0];
	let formatList = [""];
	for c in format
		if contains(formatList[formatList.size - 1], c) {
			formatList[formatList.size - 1] += c;
		}
		else {
			formatList += [c];
		}

	// Remove initial empty
	formatList = formatList[1->formatList.size];
	matcher += [[name, #:(args) {
		// Make binary string based on args
		let res = "";
		for fmt in formatList {
			if fmt[0] == "0" or fmt[0] == "1"
				res += fmt;
			else if fmt[0] == "a"
				res += toBinString(args[0], fmt.size);
			else if fmt[0] == "b"
				res += toBinString(args[1], fmt.size);
			else if fmt[0] == "c"
				res += toBinString(args[2], fmt.size);
		}
		ret res;
	}]];
};

// a b c ... are order of params
gen(".word",	"aaaa aaaa aaaa aaaa aaaa aaaa aaaa aaaa");
gen("add",		"0000 00bb bbbc cccc aaaa a000 0010 0000");
gen("sub",		"0000 00bb bbbc cccc aaaa a000 0010 0010");
gen("mult",		"0000 00aa aaab bbbb 0000 0000 0001 1000");
gen("multu",	"0000 00aa aaab bbbb 0000 0000 0001 1001");
gen("div",		"0000 00aa aaab bbbb 0000 0000 0001 1010");
gen("divu",		"0000 00aa aaab bbbb 0000 0000 0001 1011");
gen("mfhi",		"0000 0000 0000 0000 aaaa a000 0001 0000");
gen("mflo",		"0000 0000 0000 0000 aaaa a000 0001 0010");
gen("lis",		"0000 0000 0000 0000 aaaa a000 0001 0100");
gen("lw",		"1000 11cc ccca aaaa bbbb bbbb bbbb bbbb");
gen("sw",		"1010 11cc ccca aaaa bbbb bbbb bbbb bbbb");
gen("slt",		"0000 00bb bbbc cccc aaaa a000 0010 1010");
gen("sltu",		"0000 00bb bbbc cccc aaaa a000 0010 1011");
gen("beq",		"0001 00aa aaab bbbb cccc cccc cccc cccc");
gen("bne",		"0001 01aa aaab bbbb cccc cccc cccc cccc");
gen("jr",		"0000 00aa aaa0 0000 0000 0000 0000 1000");
gen("jalr",		"0000 00aa aaa0 0000 0000 0000 0000 1001");

let startsWith => (string, sub) {
	if string.size >= sub.size {
		if string[0->sub.size] == sub
			ret true;
	}
	ret false;
};

let binToDec => (binString) {
	let res = 0;
	for a in binString {
		res *= 2;
		if a == "1"
			res += 1;
	}
	ret res;
};

let binToHex => (binString) {
	if (binString.size != 32) {
		"This only works with 32bit binary strings!";
		ret "0x00000000";
	}
	let res = "0x";
	for i in 0->8 {
		res += "0123456789abcdef"[binToDec(binString[(i * 4) -> ((i + 1) * 4)])];
	}
	ret res;
};

let hexToInt => (hex) {
	if startsWith(hex, "0x") {
		hex = hex[2->hex.size];
	}
	let res = 0;
	for c in hex {
		res *= 16;
		if contains("0123456789", c)
			res += c.val - "0".val;
		else if contains("abcdef", c)
			res += 10 + c.val - "a".val;
		else if contains("ABCDEF", c)
			res += 10 + c.val - "A".val;
		else
			"Invalid character " + c + " in hex string";
	}
	ret res;
};

let splitParts => (line) {
	// Dedups spaces, replaces "(", ")" and ","
	let new = "";
	for c in line
		if c == "(" or c == ")" or c == "," or c == " " {
			if new.size > 0
				if new[new.size - 1] != " "
					new += " "
		}
		else
			new += c
	let parts = new / " ";
	let res = [];
	for part in parts
		if startsWith(part, "$")
			// Is a register
			res += int(part[1->part.size]);
		else if startsWith(part, "0x")
			// Is a hex
			res += hexToInt(part);
		else
			res += part;
	ret res;
};

let usage => () {
	"usage: wendy main.w [format] [inputFile]";
	"	format denotes how each line will come out:";
	"		`binary`: 32bit binary string";
	"		`hex`: hex string";
	"		`cs241`: hex string with `.word` in front";
};

let main => () {
	let args = System.program.args;

	if (args.size != 2) {
		usage();
		ret;
	}
	
	let contents = io.readFile(args[1]);
	
	let lines = contents / "\n";
	lines = map(#:(line) {
		let parts = splitParts(line);
		for instruction in matcher
			if parts[0] == instruction[0] {
				ret instruction[1](parts[1->parts.size]);
			}
		"Instruction " + parts[0] + " not found!";
		ret "";
	}, lines);

	for line in lines {
		if args[0] == "binary" line
		else if args[0] == "hex" binToHex(line)
		else if args[0] == "cs241" ".word " + binToHex(line);
		else {
			usage();
			ret;
		}
	}
};


main();
