#!/bin/sh

#  oclint_result.sh
#  TTOCLint
#
#  Created by le tong on 2019/11/26.
#  Copyright © 2019 iOS. All rights reserved.
#source ~/.bashrc
myworkspace=TTOCLint.xcworkspace
myscheme=TTOCLint

# clean cache
rm -rf ~/Library/Developer/Xcode/DerivedData/;
rm compile_commands.json;
rm oclint_result.xml;

# clean -- build -- OCLint analyse
echo 'start analyse';
xcodebuild -workspace $myworkspace -scheme $myscheme clean&&
xcodebuild -workspace $myworkspace -scheme $myscheme \
-configuration Debug GCC_PRECOMPILE_PREFIX_HEADER=YES CLANG_ENABLE_MODULE_DEBUGGING=NO COMPILER_INDEX_STORE_ENABLE=NO \
-destination 'platform=iOS Simulator,name=iPhone X' \
| xcpretty -r json-compilation-database -o compile_commands.json&&oclint-json-compilation-database -e Pods -e node_modules -- \
oclint-json-compilation-database -e APPDelegate -- \

-report-type pmd \
-rc LONG_LINE=300 \
-rc LONG_METHOD=200 \
-rc LONG_VARIABLE_NAME=40 \
-rc LONG_CLASS=3000 \
-max-priority-1=1000 \
-max-priority-2=1000 \
-max-priority-3=2000 \
-disable-rule=UnusedMethodParameter \
-disable-rule=AvoidPrivateStaticMembers \
-disable-rule=ShortVariableName \
-allow-duplicated-violations=false >> oclint_result.xml; \
echo 'end analyse';

# echo result
if [ -f ./oclint_result.xml ];
then echo 'done';
else echo 'failed';
fi

#忽略可检测文件 clint-json-compilation-database -e APPDelegate（文件夹名） -- \
#通过//!OCLint注释的方式，不让OCLint检查
#可以用 -rc 改变检查规则的默认值
#禁止某一个规则的使用可以使用命令-disable-rule
#OCLint 0.13 includes 71 rules : http://docs.oclint.org/en/stable/rules/index.html


