#!/bin/sh

# 参数合法性判断

if [ $# != 7 ]; then
    echo "./bin/avp_platform_startup.sh [USER_NAME] [INPUT_PAT] [OUTPUT_PAT] [MAP_TASKS] [REDUCE_TASKS] [CLASS_ID] [CODE_TYPE]"
    exit
fi

# GLOBAL VARS
USER_NAME=$1
INPUT_PAT=$2
OUTPUT_PAT=$3
MAP_TASKS=$4
REDUCE_TASKS=$5
CLASS_ID=$6
CODE_TYPE=$7

# Hadoop Start Area
/home/work/software/hadoop/bin/hadoop jar /home/work/software/hadoop/contrib/streaming/hadoop-streaming.jar \
    -input /home/$USER/$USER_NAME/output/webpage/$INPUT_PAT/ \
    -output /home/$USER/$USER_NAME/output/avp/avp-extract-$USER_NAME\_nlp_$OUTPUT_PAT-`date +%F-%H-%M-%S` \
    -mapper "avp_extract_mapper.sh . . $CODE_TYPE" \
    -reducer "avp_extract_reducer.sh" \
    -file ./script/avp_extract_mapper.sh \
    -file ./script/avp_extract_reducer.sh \
    -file ./script/extract_tools/tidy_page.py \
    -file ./script/decode.pl \
    -file ./script/extract_tools/format.py \
    -file ./script/extract_tools/extract_tool.py \
    -file ./class/$CLASS_ID/site.list \
    -file ./class/$CLASS_ID/*.conf \
    -jobconf mapred.job.name=$USER_NAME\_avp_platform_extract_tools_$OUTPUT_PAT \
    -jobconf mapred.map.tasks=$MAP_TASKS \
    -jobconf mapred.reduce.tasks=$REDUCE_TASKS
