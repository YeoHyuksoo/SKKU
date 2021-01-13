package com.example.map_pa;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;

public class ListviewAdapter extends BaseAdapter {
    private ArrayList<ListviewItem> listviewItemList = new ArrayList<ListviewItem>() ;

    LayoutInflater inflater;

    public ListviewAdapter() {

    }

    @Override
    public int getCount() {
        return listviewItemList.size();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final int pos = position;
        final Context context = parent.getContext();

        if (convertView == null) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.listview_item, parent, false);
        }

        TextView contentText = (TextView) convertView.findViewById(R.id.contentView) ;
        TextView tagsText = (TextView) convertView.findViewById(R.id.tagsView) ;
        TextView usernameText = (TextView) convertView.findViewById(R.id.usernameView) ;
        ImageView imageView = (ImageView) convertView.findViewById(R.id.imageView);
        ImageView imageView2 = (ImageView)convertView.findViewById(R.id.imageView2);

        ListviewItem listViewItem = listviewItemList.get(position);

        contentText.setText(listViewItem.getContent());
        tagsText.setText(listViewItem.getTags());
        usernameText.setText(listViewItem.getUsername());

        //imageView.setImageBitmap(listViewItem.getImageview());
        if(listViewItem.getImageview().equals("")){
            Bitmap bm = null;
            imageView.setImageBitmap(bm);
        }

        else{
            Picasso.get().load(listViewItem.getImageview()).into(imageView);
        }
        if(listViewItem.getImageview2().equals("")){
            Bitmap bm2 = null;
            imageView2.setImageBitmap(bm2);
        }

        else{
            Picasso.get().load(listViewItem.getImageview2()).into(imageView2);
        }

        return convertView;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public Object getItem(int position) {
        return listviewItemList.get(position) ;
    }

    public void addItem(String username, String content, String tags, String image, String image2) {
        ListviewItem item = new ListviewItem();

        item.setUsername(username);
        item.setContent(content);
        item.setTags(tags);
        //item.setImageview(image);
        item.setImageview(image);
        item.setImageview2(image2);

        listviewItemList.add(item);
    }

    /*public void addItem(String username, String content, String tags, String image) {
        ListviewItem item = new ListviewItem();

        item.setUsername(username);
        item.setContent(content);
        item.setTags(tags);

        item.setImageview(image);

        listviewItemList.add(item);
    }*/

    public void clearItem(){
        listviewItemList.clear();
    }
}
