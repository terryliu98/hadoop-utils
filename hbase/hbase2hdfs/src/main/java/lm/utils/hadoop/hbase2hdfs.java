package lm.utils.hadoop;

import java.io.IOException;
import java.util.Map.Entry;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.*;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hbase.mapreduce.TableMapper;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

/**
 * Created by liumiao on 2016/1/14.
 */
public class hbase2hdfs {
    public static void main(String[] args) throws Exception {
        String tablename = "guid_uid_relationship";
        Configuration config = HBaseConfiguration.create();
        config.set("hbase.zookeeper.quorum", "yhd-jqhadoop167.int.yihaodian.com,yhd-jqhadoop169.int.yihaodian.com,yhd-jqhadoop166.int.yihaodian.com,yhd-jqhadoop176.int.yihaodian.com,yhd-jqhadoop174.int.yihaodian.com");
        config.set("mapreduce.job.queuename", "tandem");
        config.set("mapreduce.job.reduces", "3");

        Job job = new Job(config,"hbase2hdfs");
        job.setJarByClass(hbase2hdfs.class);     // class that contains mapper and reducer

        FileOutputFormat.setOutputPath(job, new Path(args[0]));
        job.setReducerClass(MyReduce.class);
        Scan scan = new Scan();
        TableMapReduceUtil.initTableMapperJob(tablename,scan,MyMapper.class, Text.class, Text.class, job);
        //调用job.waitForCompletion(true) 执行任务，执行成功后退出；
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }

    public static class MyMapper extends TableMapper<Text, Text> {
        @Override
        protected void map(ImmutableBytesWritable key, Result value, Context context)
                throws IOException, InterruptedException {
            StringBuffer sb = new StringBuffer("");
            //if(value.getFamilyMap("relation".getBytes()).entrySet().size() == 1) {
            for (Entry<byte[], byte[]> entry : value.getFamilyMap("relation".getBytes()).entrySet()) {
                String str = new String(entry.getValue());
                //将字节数组转换为String类型
                if (str != null || !str.equals("null")) {
                    sb.append(str);
                }
                context.write(new Text(key.get()), new Text(new String(sb)));
            }
            // }
        }
    }

    public static class MyReduce extends Reducer<Text, Text, Text, Text> {
        private Text result = new Text();
        @Override
        protected void reduce(Text key, Iterable<Text> values,Context context)
                throws IOException, InterruptedException {
            for(Text val:values){
                result.set(val);
                context.write(key, result);
            }
        }
    }
}
