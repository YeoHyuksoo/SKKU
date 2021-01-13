package com.example.map_pa;

import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
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
 * Use the {@link PersonalFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class PersonalFragment extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    ListView listView2;
    ListviewAdapter adapter2;
    ImageView imageView;
    String key = "";
    String info[] = new String[4];
    TextView perTextview;

    DatabaseReference mPostReference;
    StorageReference mStorageRef;

    String Username = "";
    StorageReference perStorageRef;
    Uri profileUri;

    public PersonalFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment PersonalFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static PersonalFragment newInstance(String param1, String param2) {
        PersonalFragment fragment = new PersonalFragment();
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
        listView2.setOnItemClickListener(new AdapterView.OnItemClickListener() {
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
        mStorageRef = FirebaseStorage.getInstance().getReference("Personal");

        View view = inflater.inflate(R.layout.fragment_personal, container, false);
        listView2 = (ListView) view.findViewById(R.id.dataList2);
        perTextview = (TextView) view.findViewById(R.id.pertextview);
        imageView = (ImageView) view.findViewById(R.id.imageView);

        Username = ((postPage)getActivity()).Username;
        Log.d("Username", Username);
        perStorageRef = FirebaseStorage.getInstance().getReference("Images");
        posting();

        return view;
    }

    public void posting(){
        final ValueEventListener postListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                adapter2 = new ListviewAdapter();
                listView2.setAdapter(adapter2);
                adapter2.clearItem();
                perTextview.setVisibility(View.INVISIBLE);

                for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                    key = postSnapshot.getKey();
                    createFirebasePost get = postSnapshot.getValue(createFirebasePost.class);
                    if(!get.username.equals(Username)) continue;

                    final String[] info = {get.username, get.content, get.tags, get.posturi};
                    perStorageRef.child(get.username+"_profile.jpg").getDownloadUrl().addOnSuccessListener(new OnSuccessListener<Uri>() {
                        @Override
                        public void onSuccess(Uri profileuri) {
                            profileUri = profileuri;
                            if(info[3].equals("")){
                                adapter2.addItem(info[0], info[1], info[2], profileUri.toString(), "");
                            }
                            else{
                                adapter2.addItem(info[0], info[1], info[2], profileUri.toString(), info[3]);
                            }

                            adapter2.notifyDataSetChanged();
                        }
                    }).addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            if(info[3].equals("")){
                                adapter2.addItem(info[0], info[1], info[2], "", "");
                            }
                            else{
                                adapter2.addItem(info[0], info[1], info[2], "", info[3]);
                            }

                            adapter2.notifyDataSetChanged();
                            /*adapter.addItem(info[0], info[1], info[2], img);
                    pubTextview.setVisibility(View.INVISIBLE);
                    imageView.setImageBitmap(img);*/
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
                adapter2.notifyDataSetChanged();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        mPostReference.child("personal").addValueEventListener(postListener);
    }
}

