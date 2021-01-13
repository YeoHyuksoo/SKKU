/*package edu.skku.map.week10;

import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "Week10 FCM Main";
    private final String uid = "MyUserId";
    private DatabaseReference mPostReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mPostReference = FirebaseDatabase.getInstance().getReference();

        FirebaseInstanceId.getInstance().getInstanceId()
                .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                    @Override
                    public void onComplete(@NonNull Task<InstanceIdResult> task) {
                        if(!task.isSuccessful()){
                            Log.w(TAG, "getInstanceId failed", task.getException());
                            return;
                        }
                        String token = task.getResult().getToken();

                        String msg = getString(R.string.msg_token_fmt, token);
                        Log.d(TAG, msg);
                        Toast.makeText(MainActivity.this, msg, Toast.LENGTH_SHORT).show();

                        FirebasePost post = new FirebasePost(token, uid, "2016312761", "Hyuksoo");
                        Map<String, Object> childUpdates = new HashMap<>();
                        Map<String, Object> postValues = null;
                        postValues = post.toMap();
                        childUpdates.put("/Notification" + uid, postValues);

                        mPostReference.updateChildren(childUpdates);
                    }
                });
    }
}*/
package edu.skku.map.week10;

import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "Week10 FCM Main";
    private final String uid = "MyUserId";
    private DatabaseReference mPostReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mPostReference = FirebaseDatabase.getInstance().getReference();

        FirebaseInstanceId.getInstance().getInstanceId()
                .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                    @Override
                    public void onComplete(@NonNull Task<InstanceIdResult> task) {
                        if (!task.isSuccessful()) {
                            Log.w(TAG, "getInstanceId failed", task.getException());
                            return;
                        }

                        // Get new Instance ID token
                        String token = task.getResult().getToken();

                        // Log and toast
                        String msg = getString(R.string.msg_token_fmt, token);
                        Log.d(TAG, msg);
                        Toast.makeText(MainActivity.this, msg, Toast.LENGTH_SHORT).show();

                        // Upload token data to firebase database.
                        FirebasePost post = new FirebasePost(token, uid, "2016312761", "Yeohyuksoo");

                        Map<String, Object> childUpdates = new HashMap<>();
                        Map<String, Object> postValues = null;

                        postValues = post.toMap();

                        childUpdates.put("/Notification/" + uid, postValues);

                        mPostReference.updateChildren(childUpdates);
                    }
                });

//        FirebaseInstanceId.getInstance().getToken();
//
//        if (FirebaseInstanceId.getInstance().getToken() != null) {
//            Log.d("Week10 FCM", "token = " + FirebaseInstanceId.getInstance().getToken());
//        }
    }
}
