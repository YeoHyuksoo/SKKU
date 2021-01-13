package edu.skku.map.pp_daanawa;

public class ListviewItem {
    private String namestr;
    private String introstr;
    private String pricestr;

    public void setName(String name) { namestr = name; }
    public void setIntro(String intro) { introstr = intro; }
    public void setPrice(String price) { pricestr = price; }

    public String getName() {
        return this.namestr;
    }
    public String getIntro() {
        return this.introstr;
    }
    public String getPrice() {
        return this.pricestr;
    }
}
