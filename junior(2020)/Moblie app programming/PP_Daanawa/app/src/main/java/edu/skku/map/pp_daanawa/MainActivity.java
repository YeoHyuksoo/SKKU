package edu.skku.map.pp_daanawa;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.kakao.auth.ISessionCallback;
import com.kakao.auth.Session;
import com.kakao.util.exception.KakaoException;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Session.getCurrentSession().addCallback(sessionCallback);
    }

    private ISessionCallback sessionCallback = new ISessionCallback() {
        @Override
        public void onSessionOpened() {
            Log.i("KAKAO_SESSION", "Login success");
            Intent intent = new Intent(MainActivity.this, SecondActivity.class);
            startActivity(intent);
        }

        @Override
        public void onSessionOpenFailed(KakaoException exception) {
            Log.e("KAKAO_SESSION", "Login fail");
        }
    };

    @Override
    protected void onDestroy(){
        super.onDestroy();
        Session.getCurrentSession().removeCallback(sessionCallback);
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data){
        if(Session.getCurrentSession().handleActivityResult(requestCode, resultCode, data)){
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

}