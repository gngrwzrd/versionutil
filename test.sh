#!/bin/bash
BIN=$1

assert() {
	echo "assert $1 == $2"
	if [ "$1" != "$2" ]; then
		echo "Assert fail $1 != $2"
		exit 1
	fi
}

echo_test() {
	echo "$1"
}

echo_test "FXO"
output=$($BIN "1")
assert "$output" "Invalid version format"

echo_test "FXN"
output=$($BIN "1.")
assert "$output" "Invalid version format"

echo_test "09FG"
output=$($BIN "1.2.")
assert "$output" "Invalid version format"

echo_test "D0L"
output=$($BIN "!~.~.~.129AFD" +patch)
assert "$output" "Invalid version format"

echo_test "F45"
output=$($BIN "1.1.1.129AFD" +patch)
assert "$output" "Invalid version format"

echo_test "4NK"
output=$($BIN "1.~+-alpha" +minor +major)
assert "$output" "Invalid version format"

echo_test "4LK3"
output=$($BIN "1.~+-alpha.1" +minor +major)
assert "$output" "Invalid version format"

echo_test "0P3"
output=$($BIN  "1.2.3-alpha1.0" --print-tag)
assert "$output" "Invalid version format"

echo_test "3FG"
output=$($BIN "!~.~.~+-alpha" +patch)
assert "$output" "Invalid version format"

echo_test "21D"
output=$($BIN "!~.~.~_+-alpha" +patch)
assert "$output" "Invalid version format"

echo_test "X87F"
output=$($BIN "!~.~.~x+-alpha" +patch)
assert "$output" "Invalid version format"

echo_test "FK3"
output=$($BIN "1.1.1F")
assert "$output" "Invalid version format"

echo_test "FKD"
output=$($BIN "1.x")
assert "$output" "Invalid version format"

echo_test "5LK3"
output=$($BIN "1:1")
assert "$output" "Invalid version format"

echo_test "45TGH"
output=$($BIN '1.2.3' --compare 1.2.)
assert "$output" "Invalid version format"

echo_test "4X43X"
output=$($BIN '1.2.3' --compare 1.)
assert "$output" "Invalid version format"

echo_test "90ORL"
output=$($BIN '1.2.3' --compare 1.2)
assert "$output" "Invalid version format"

echo_test "DL43"
output=$($BIN '1.2' --compare 1.2.4)
assert "$output" "Invalid version format"

##############################################

echo_test "F34"
output=$($BIN "1.2")
assert "$output" "1.2"

echo_test "40P"
output=$($BIN "~.1")
assert "$output" "0.1"

echo_test "43F"
output=$($BIN "1.~")
assert "$output" "1.0"

echo_test "4RG"
output=$($BIN "~.~")
assert "$output" "0.0"

echo_test "59F"
output=$($BIN "!~.2" +major)
assert "$output" "0.2"

echo_test "9FT"
output=$($BIN "~.2" +major)
assert "$output" "0.2"

echo_test "0RF"
output=$($BIN "2.3" +major)
assert "$output" "3.3"

echo_test "4FD"
output=$($BIN "2.~" +minor)
assert "$output" "2.0"

echo_test "ULR"
output=$($BIN "2.2" +minor)
assert "$output" "2.3"

echo_test "EPL"
output=$($BIN "1.1" +minor +major)
assert "$output" "2.2"

echo_test "FLK"
output=$($BIN "1.1" +patch)
assert "$output" "1.1"

echo_test "LKI"
output=$($BIN "1.1-alpha")
assert "$output" "1.1-alpha"

echo_test "D9I"
output=$($BIN "1.1-alpha" +minor)
assert "$output" "1.2-alpha"

echo_test "0P3"
output=$($BIN "1.1-alpha" +minor +major)
assert "$output" "2.2-alpha"

echo_test "13R"
output=$($BIN "1.~-alpha" +minor +major)
assert "$output" "2.0-alpha"

## Test Long Format Script Output

echo_test "X9LI"
output=$($BIN 1.2.3)
assert "$output" "1.2.3"

echo_test "X8L4"
output=$($BIN 1.2.3 +major)
assert "$output" "2.2.3"

echo_test "4FGHD"
output=$($BIN 1.2.3 +minor)
assert "$output" "1.3.3"

echo_test "DP3F"
output=$($BIN 1.2.3 +patch)
assert "$output" "1.2.4"

echo_test "DF34"
output=$($BIN 1.2.3 +major +minor)
assert "$output" "2.3.3"

echo_test "4BN6"
output=$($BIN 1.2.3 +major +patch)
assert "$output" "2.2.4"

echo_test "X9GB"
output=$($BIN 1.2.3 +minor +patch)
assert "$output" "1.3.4"

echo_test "X84R"
output=$($BIN 1.2.3 +major +minor +patch)
assert "$output" "2.3.4"

echo_test "X09RF"
output=$($BIN "~.2.3")
assert "$output" "0.2.3"

echo_test "F4GN"
output=$($BIN "~.~.3")
assert "$output" "0.0.3"

echo_test "ZS3R"
output=$($BIN "~.~.~")
assert "$output" "0.0.0"

echo_test "ZHJK"
output=$($BIN "!1.2.3")
assert "$output" "1.2.3"

echo_test "X09D"
output=$($BIN "!1.2.3" +major)
assert "$output" "1.2.3"

echo_test "AS3F"
output=$($BIN "!1.2.3" +minor)
assert "$output" "1.2.3"

echo_test "04F3"
output=$($BIN "!1.2.3" +patch)
assert "$output" "1.2.3"

echo_test "X2FH8"
output=$($BIN "!1.2.3" +major +minor)
assert "$output" "1.2.3"

echo_test "X05G"
output=$($BIN "!1.2.3" +major +patch)
assert "$output" "1.2.3"

echo_test "X04H"
output=$($BIN "!1.2.3" +minor +patch)
assert "$output" "1.2.3"

echo_test "DJ4LK"
output=$($BIN "!1.2.3" +major +minor +patch)
assert "$output" "1.2.3"

echo_test "X9L4R"
output=$($BIN "!~.2.3" +major)
assert "$output" "0.2.3"

echo_test "DL4FH"
output=$($BIN "!1.~.3" +minor)
assert "$output" "1.0.3"

echo_test "L3RB"
output=$($BIN "!1.2.~" +patch)
assert "$output" "1.2.0"

echo_test "D09ER"
output=$($BIN "!~.~.~-alpha" +patch)
assert "$output" "0.0.0-alpha"

echo_test "MHEF"
output=$($BIN "!~.~.~+alpha" +patch)
assert "$output" "0.0.0+alpha"

## Test Printing

echo_test "M4RH"
output=$($BIN  "1.2.3" --print-patch)
assert "$output" "3"

echo_test "M8L4"
output=$($BIN  "1.2.3" --print-major)
assert "$output" "1"

echo_test "MTR8"
output=$($BIN  "1.2.3" --print-minor)
assert "$output" "2"

echo_test "M4FE"
output=$($BIN "1.~.3" --print-minor)
assert "$output" "0"

echo_test "M3FL"
output=$($BIN "!1.~.2" --print-minor +minor)
assert "$output" "0"

echo_test "3RFL"
output=$($BIN "1.1.~" --print-patch +patch)
assert "$output" "0"

echo_test "19FM"
output=$($BIN "1.2.3" +patch --print-patch)
assert "$output" "4"

echo_test "FLMD"
output=$($BIN "1.2.3" --print-patch +patch)
assert "$output" "4"

## Test Comparison for Long Format

echo_test "4F8"
output=$($BIN "1.2.3" --gt "1.3.4")
assert "$output" "false"

echo_test "4ZD"
output=$($BIN "1.2.3-alpha" --gt "1.3.4-alpha")
assert "$output" "false"

echo_test "LD8"
output=$($BIN "1.2.3" --lt "1.3.4")
assert "$output" "true"

echo_test "4FV"
output=$($BIN "1.2.3" --eq "1.2.3")
assert "$output" "true"

echo_test "GJK"
output=$($BIN "1.2.3" --compare "1.3.4")
assert "$output" "lt"

echo_test "KL3"
output=$($BIN "1.4.3" --compare "1.3.4")
assert "$output" "gt"

echo_test "LO4"
output=$($BIN "1.4.3" --compare "1.4.3")
assert "$output" "eq"

echo_test "D4F"
output=$($BIN "1.4.~" --compare "1.4.0")
assert "$output" "eq"

echo_test "DX4"
output=$($BIN "!1.4.~" --compare "1.4.0")
assert "$output" "eq"

## TODO test comparison of short format

echo_test "4LK1"
output=$($BIN "1.2" --compare "1.2")
assert "$output" "eq"

echo_test "LM4R"
output=$($BIN "1.~" --compare "1.~")
assert "$output" "eq"

echo_test "19FD"
output=$($BIN "~.1" --compare "~.1")
assert "$output" "eq"

echo_test "39FX"
output=$($BIN "1.1-alpha04" --compare "1.1-alpha04")
assert "$output" "eq"

echo_test "93T5"
output=$($BIN "1.1+04Alpha" --compare "1.2+Alpha")
assert "$output" "lt"

echo_test "45TG"
output=$($BIN "1.2+04Alpha" --compare "1.1+Alpha")
assert "$output" "gt"

echo_test "67GJ"
output=$($BIN "1.2+04Alpha" --gt "1.1+Alpha")
assert "$output" "true"

echo_test "XML4"
output=$($BIN "1.2+04Alpha" --lt "1.1+Alpha")
assert "$output" "false"

echo_test "X04K"
output=$($BIN "1.1+04Alpha" --gt "1.2+Alpha")
assert "$output" "false"

echo_test "0PL3"
output=$($BIN "1.1+04Alpha" --lt "1.2+Alpha")
assert "$output" "true"

echo ""
echo "All Tests Pass"
