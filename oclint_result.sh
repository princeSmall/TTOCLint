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

| xcpretty -r json-compilation-database -o compile_commands.json&&
# OCLint的规则 可以通过 -e 参数忽略指定的文件，比如忽略Pods文件夹,AppDelegate.m文件
oclint-json-compilation-database -e Pods -e node_modules -- \
oclint-json-compilation-database -e AppDelegate.m -- \

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
