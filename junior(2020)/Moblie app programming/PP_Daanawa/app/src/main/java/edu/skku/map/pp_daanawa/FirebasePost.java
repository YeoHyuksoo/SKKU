package edu.skku.map.pp_daanawa;

import java.util.HashMap;
import java.util.Map;

public class FirebasePost {
    public String name;
    public String intro;
    public long price;

    public FirebasePost(){

    }

    public FirebasePost(String name, String intro, Long price){
        this.name = name;
        this.intro =intro;
        this.price = price;
    }

    public Map<String, Object> toMap(){
        HashMap<String, Object> result = new HashMap<>();
        result.put("name", name);
        result.put("intro", intro);
        result.put("price", price);

        return result;
    }

}
