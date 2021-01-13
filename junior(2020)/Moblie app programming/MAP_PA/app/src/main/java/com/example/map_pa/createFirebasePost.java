package com.example.map_pa;

import java.util.HashMap;
import java.util.Map;

public class createFirebasePost {
    public String username;
    public String content;
    public String tags;

    public String posturi;

    public createFirebasePost(){

    }

    public createFirebasePost(String username, String content, String tags,   String posturi){
        this.username = username;
        this.content = content;
        this.tags = tags;

        this.posturi = posturi;
    }

    public Map<String, Object> toMap(){
        HashMap<String, Object> result = new HashMap<>();
        result.put("username", username);
        result.put("content", content);
        result.put("tags", tags);

        result.put("posturi", posturi);

        return result;
    }
}
