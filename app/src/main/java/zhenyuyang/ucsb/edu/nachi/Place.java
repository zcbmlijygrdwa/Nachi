package zhenyuyang.ucsb.edu.nachi;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by Zhenyu on 2017-11-26.
 */

public class Place{
    String name;
    public boolean isVoted;
    HashMap<String,String> hm;



    public Place(String nmaeIn){
        this.name = nmaeIn;
        hm = new HashMap<String,String>();
        isVoted = false;
    }

    public void addMember(String memberName, String vote){
        hm.put(memberName,vote);
    }

    public String toString(){
        String output = "";
        output ="";
        for(HashMap.Entry entry:hm.entrySet()){
            //output+=entry.getKey()+" = "+entry.getValue()+" \n";
            if(entry.getValue().equals("0")){
                output+=entry.getKey()+" denied\n";
            }
            else {
                output+=entry.getKey()+" is going\n";
            }
        }
        return output;
    }

    public String voteStatus(){
        String output = "";
        output = "";
        for(HashMap.Entry entry:hm.entrySet()){
            output+=entry.getKey()+" = "+entry.getValue()+", ";
        }
        return output;
    }


}
