package com.example.map_pa;

public class ListviewItem {
    private String contentstr;
    private String tagsstr;
    private String usernamestr;

    private String imageview;
    private String imageview2;

    public void setContent(String content) {
        contentstr = content;
    }
    public void setTags(String tags) {
        tagsstr = tags;
    }
    public void setUsername(String username) { usernamestr = username; }
    public void setImageview(String image) { imageview = image; }
    public void setImageview2(String image2) { imageview2 = image2; }

    public String getContent() {
        return this.contentstr;
    }
    public String getTags() {
        return this.tagsstr;
    }
    public String getUsername() {
        return this.usernamestr;
    }
    public String getImageview() { return this.imageview; }
    public String getImageview2() { return this.imageview2; }
}
