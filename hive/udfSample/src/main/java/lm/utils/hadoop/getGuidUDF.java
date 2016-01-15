package lm.utils.hadoop;

import org.apache.hadoop.hive.ql.exec.UDF;

import java.math.BigInteger;
import java.util.regex.Pattern;

/**
 * Created by liumiao on 2016/1/14.
 */
public class getGuidUDF extends UDF {
    public String evaluate(String guid, String key) {
        if(guid!=null) {
            return guid;
        } else {
            if(isNumeric(key) && key.length()>=3 && key.length() <=9) {
                return null;
            } else {
                return key;
            }
        }
    }

    private static boolean isNumeric(String str){
        Pattern pattern = Pattern.compile("[0-9]*");
        return pattern.matcher(str).matches();
    }
}
