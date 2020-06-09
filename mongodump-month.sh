#!/bin/sh
#mongo按月归档数据

#备份任务名称
TaskName=''

#MongoDB数据库配置
Host='127.0.0.1'
Port='27017'
User=''
Pass=''
Authdb=''
DB=''
Coll=''

#筛选的字段 
#此处的date为string类型，如果时间格式为ISODate或者DateTime类型的话需要转换后才能使用
DateKey=''

#mongo/bin目录
SourcePath=''

#导出文件路径
TargetPath=''

#导出数据的时间段
StartMonth='2019-01'
EndMonth='2019-12'

#生成月份开始和结束日期
StartSec=`date -d "${StartMonth}-01" +%s`
EndSec=`date -d "${EndMonth}-01" +%s`

while [ $StartSec -le $EndSec ]; do

    day_curr=`date -d @$StartSec +%Y-%m-%d`
    MonthCurr=`date -d @$StartSec +%Y-%m`

    #月份开始日期
    StartDate=`date -d"${MonthCurr}-01" "+%Y-%m-01"`      
    TmpDt=`date -d"${MonthCurr}-01 +1 months" "+%Y-%m-01"`   
 
    #月份结束日期
    EndDate=`date -d "${TmpDt} -1 day" "+%Y-%m-%d"`      

    #输出数据库信息和生成的日期
    echo "=========>     开始导出${DB}数据库${Coll}集合数据：$MonthCurr $StartDate $EndDate      <========="  

    ###处理过程
    ##导出数据
    
    #创建存储目录
    mkdir -p ${TargetPath}/${DB}/${Coll}/$MonthCurr

    #筛选的字段
    DateKey='date'
    
    #生成查询json
    QueryJson='{"'${DateKey}'":{$gte:"'${StartDate}'", $lte:"'${EndDate}'"}}'

    #导出数据
    ${SourcePath}mongodump --port ${Port} -u ${User} -p ${Pass} -d ${DB} -c ${Coll} --authenticationDatabase ${Authdb} -q="${QueryJson}" -o ${TargetPath}/${DB}/${Coll}/$MonthCurr
    
    #输出存储位置
    echo "=========>     已导出$MonthCurr数据，存储位置：${TargetPath}/${DB}/${Coll}/$MonthCurr   <========="

    # 一次结束重置月份 
    let StartSec=`date -d "${MonthCurr}-01 +1 months" +%s`

done
