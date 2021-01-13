package edu.skku.map.pp_daanawa;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;

public class ListviewAdapter extends BaseAdapter implements View.OnClickListener {
    private ArrayList<ListviewItem> listviewItemList = new ArrayList<ListviewItem>() ;

    HashMap<Integer, String> linkHash = new HashMap<>();
    LayoutInflater inflater;

    public interface ListBtnClickListener {
        void onListBtnClick(int position) ;
    }

    int resourceId;
    private ListBtnClickListener listBtnClickListener ;

    public ListviewAdapter() {

    }
    ListviewAdapter(Context context, int resource, ListBtnClickListener clickListener) {


        // resource id 값 복사. (super로 전달된 resource를 참조할 방법이 없음.)
        this.resourceId = resource ;

        this.listBtnClickListener = clickListener ;
    }

    @Override
    public int getCount() {
        return listviewItemList.size();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        linkhashing();
        final int pos = position;
        final Context context = parent.getContext();

        if (convertView == null) {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.listview_item, parent, false);
        }

        final TextView nameText = (TextView) convertView.findViewById(R.id.nameView) ;
        TextView introText = (TextView) convertView.findViewById(R.id.introView) ;
        TextView priceText = (TextView) convertView.findViewById(R.id.priceView) ;

        ListviewItem listViewItem = listviewItemList.get(position);

        nameText.setText(listViewItem.getName());
        introText.setText(listViewItem.getIntro());
        priceText.setText(listViewItem.getPrice());

        Button button = (Button) convertView.findViewById(R.id.inbucket);
        button.setTag(position);
        button.setOnClickListener(this);

        nameText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(context, "선택: "+pos+"-"+nameText.getText().toString(), Toast.LENGTH_SHORT).show();
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://shop.danawa.com/pc/?controller=estimateDeal&methods=productInformation&productSeq="+linkHash.get(pos)));
                context.startActivity(intent);
            }
        });

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

    public void addItem(String name, String intro, String price) {
        ListviewItem item = new ListviewItem();

        item.setName(name);
        item.setIntro(intro);
        item.setPrice(price);

        listviewItemList.add(item);
    }

    public void clearItem(){
        listviewItemList.clear();
    }

    public void onClick(View v) {
        // ListBtnClickListener(MainActivity)의 onListBtnClick() 함수 호출.
        if (this.listBtnClickListener != null) {
            this.listBtnClickListener.onListBtnClick((int)v.getTag()) ;
        }
    }
    public void linkhashing(){
        linkHash.put(0, "9485676");
        linkHash.put(1, "9866466");
        linkHash.put(2, "7310233");
        linkHash.put(3, "7628938");
        linkHash.put(4, "4597633");
        linkHash.put(5, "11308551");
        linkHash.put(6, "11405586");
        linkHash.put(7, "7059166");
        linkHash.put(8, "8459829");
        linkHash.put(9, "8459973");
        linkHash.put(10, "6508748");
        linkHash.put(11, "6013975");
        linkHash.put(12, "6370926");
        linkHash.put(13, "9276801");
        linkHash.put(14, "5937666");
        linkHash.put(15, "5941995");
        linkHash.put(16, "5791861");
        linkHash.put(17, "10120452");
        linkHash.put(18, "5834210");
        linkHash.put(19, "6545078");
        linkHash.put(20, "1706996");
        linkHash.put(21, "8038456");
        linkHash.put(22, "9821508");
        linkHash.put(23, "1928673");
        linkHash.put(24, "4027451");
        linkHash.put(25, "9569508");
        linkHash.put(26, "11108034");
        linkHash.put(27, "5921371");

    }
}
