package com.example.map_pa;

import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link PublicFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class PublicFragment extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    ListView listView;
    ListviewAdapter adapter;
    ImageView imageView;
    String key = "";
    String info[] = new String[4];
    TextView pubTextview;

    DatabaseReference mPostReference;
    StorageReference mStorageRef;

    String Username = "";
    StorageReference pubStorageRef;
    Uri profileUri;

    public PublicFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment PublicFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static PublicFragment newInstance(String param1, String param2) {
        PublicFragment fragment = new PublicFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

            }
        });
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment

        mPostReference = FirebaseDatabase.getInstance().getReference();
        mStorageRef = FirebaseStorage.getInstance().getReference("Public");

        View view = inflater.inflate(R.layout.fragment_public, container, false);
        listView = (ListView) view.findViewById(R.id.dataList);
        pubTextview = (TextView) view.findViewById(R.id.pubtextview);
        imageView = (ImageView) view.findViewById(R.id.imageView);

        Username = ((postPage)getActivity()).Username;
        pubStorageRef = FirebaseStorage.getInstance().getReference("Images");

        posting();

        return view;
    }

    public void posting(){
        final ValueEventListener postListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                adapter = new ListviewAdapter();
                listView.setAdapter(adapter);
                adapter.clearItem();
                pubTextview.setVisibility(View.INVISIBLE);

                for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                    key = postSnapshot.getKey();
                    createFirebasePost get = postSnapshot.getValue(createFirebasePost.class);
                    final String[] info = {get.username, get.content, get.tags, get.posturi};

                    pubStorageRef.child(get.username+"_profile.jpg").getDownloadUrl().addOnSuccessListener(new OnSuccessListener<Uri>() {
                        @Override
                        public void onSuccess(Uri profileuri) {
                            profileUri = profileuri;
                            if(info[3].equals("")){
                                adapter.addItem(info[0], info[1], info[2], profileUri.toString(), "");
                            }
                            else{
                                adapter.addItem(info[0], info[1], info[2], profileUri.toString(), info[3]);
                            }
                            
                            adapter.notifyDataSetChanged();
                        }
                    }).addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            if(info[3].equals("")){
                                adapter.addItem(info[0], info[1], info[2], "", "");
                            }
                            else{
                                adapter.addItem(info[0], info[1], info[2], "", info[3]);
                            }

                            adapter.notifyDataSetChanged();
                        }
                    });

                    /*StorageReference Ref = mStorageRef.child(key+"_image.jpg");
                    final long ONE_MEGABYTE = 1024*1024;
                    Ref.getBytes(ONE_MEGABYTE).addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception exception) {

                        }
                    }).addOnSuccessListener(new OnSuccessListener<byte[]>() {
                        @Override
                        public void onSuccess(byte[] bytes) {
                            Log.d("ok3", bytes.length+"");
                            Bitmap image = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                            //imageView.setImageBitmap(image);
                            img[0] = image;
                        }
                    });*/

                    /*adapter.addItem(info[0], info[1], info[2], img);
                    pubTextview.setVisibility(View.INVISIBLE);
                    imageView.setImageBitmap(img);*/
                }
                adapter.notifyDataSetChanged();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        mPostReference.child("public").addValueEventListener(postListener);
    }
}
