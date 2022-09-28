#!/bin/bash
JAVA_PATH=/usr/local/jdk8 #JDK目录
SERVER_NAME=$1 #服务名称 如 base-server
FILECOUNT=$2; #生成几个jstack文件
SLEEP_TIME=3; #间隔多久生成下一个jstack文件
outDir=/opt/jstack_log/${SERVER_NAME}/  #jstack文件输出路径

#如果不输入参数 退出
if [ -z ${SERVER_NAME} ]; then
    echo "ERROR: Enter the [SERVER_NAME] please, Such as 'sh jstack_tool.sh SERVER_NAME FILE_COUNT' "
    exit 0;
fi

#如果不输入参数 退出
if [ -z ${FILECOUNT} ]; then
    echo "ERROR: Enter the [FILECOUNT] please, Such as 'sh jstack_tool.sh SERVER_NAME FILE_COUNT' "
    exit 0;
fi

if [ ! -d "$outDir" ]; then
mkdir -p "$outDir"
fi

#awk的用法，一行中的打印第二个参数，表示进程ID
PIDS=`ps -ef | grep  java | grep "${SERVER_NAME}" |awk '{print $2}'`
echo $PIDS
#校验进程ID是否存在
if [ -z "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME does not started"
    exit 1
fi
#校验获取到的PID是否唯一
pid_len=${#PIDS[*]}
if [ ${pid_len} != 1 ]; then
    echo "ERROR: The $SERVER_NAME length is ${pid_len} . The PID length must be 1,please correct the shell script  "
    exit 1
fi

# 循环次数是用户指定的
for((i=0; i < "$FILECOUNT"; i++))
do

    #定义输出文件的路径
    current=`date +"%Y%m%d%H%M_%S"`
    filePath="${outDir}jstack_${SERVER_NAME}_${PIDS}_${current}.log"

    echo "Doing jstack the $SERVER_NAME ..."
    for PID in $PIDS ; do
        #先用jstack命令打印出堆栈信息
        ${JAVA_PATH}/bin/jstack -l $PID > $filePath
        echo "jstack dump Success!"
        echo "dump File: ${filePath}"
        #睡眠1秒

        # 可以选择是否在末尾追加JVM内存信息

        ##sleep 1
        ###使用jmap -heap 在文件末尾追加JVM内存信息。
        ##${JAVA_PATH}/bin/jmap -heap  $PID >> $filePath
        ##echo "jmap -heap Success!"

    done
    sleep ${SLEEP_TIME};

done