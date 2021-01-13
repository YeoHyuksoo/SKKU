package edu.skku.map.pp_daanawa;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.kakao.network.ErrorResult;
import com.kakao.usermgmt.UserManagement;
import com.kakao.usermgmt.callback.LogoutResponseCallback;
import com.kakao.usermgmt.callback.MeV2ResponseCallback;
import com.kakao.usermgmt.response.MeV2Response;
import com.kakao.usermgmt.response.model.Profile;
import com.kakao.usermgmt.response.model.UserAccount;
import com.kakao.util.OptionalBoolean;

import java.io.InputStream;

public class SecondActivity extends AppCompatActivity {

    String name = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_second);

        final ImageView imageview = findViewById(R.id.imageView);

        UserManagement.getInstance()
                .me(new MeV2ResponseCallback() {
                    @Override
                    public void onSessionClosed(ErrorResult errorResult) {
                        Log.e("KAKAO_API", "세션이 닫혀 있음: " + errorResult);
                    }

                    @Override
                    public void onFailure(ErrorResult errorResult) {
                        Log.e("KAKAO_API", "사용자 정보 요청 실패: " + errorResult);
                    }

                    @Override
                    public void onSuccess(MeV2Response result) {
                        TextView memberinfo = findViewById(R.id.name);
                        Log.i("KAKAO_API", "사용자 아이디: " + result.getId());

                        UserAccount kakaoAccount = result.getKakaoAccount();

                        if (kakaoAccount != null) {
                            // 프로필
                            Profile profile = kakaoAccount.getProfile();

                            if (profile != null) {
                                Log.d("KAKAO_API", "nickname: " + profile.getNickname());
                                name = profile.getNickname();
                                memberinfo.setText(name+"님, 반갑습니다");
                                String profileimage = profile.getProfileImageUrl();
                                //Log.d("KAKAO_API", "profile image: " + profile.getProfileImageUrl());
                                if(profileimage!=null){
                                    new DownloadImageTask(imageview).execute(profileimage);
                                }
                                Log.d("KAKAO_API", "thumbnail image: " + profile.getThumbnailImageUrl());

                            } else if (kakaoAccount.profileNeedsAgreement() == OptionalBoolean.TRUE) {
                                // 동의 요청 후 프로필 정보 획득 가능

                            } else {
                                // 프로필 획득 불가
                            }
                        }
                    }
                });
        Button marketbtn = (Button) findViewById(R.id.gomarket);
        marketbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(SecondActivity.this, MarketPage.class);
                intent.putExtra("Username", name);
                startActivity(intent);
            }
        });
        Button bucketbtn = (Button) findViewById(R.id.gobucket);
        bucketbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(SecondActivity.this, BucketPage.class);
                intent.putExtra("Username", name);
                startActivity(intent);
            }
        });
        Button logoutbtn = (Button) findViewById(R.id.logout_button);
        logoutbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                UserManagement.getInstance()
                        .requestLogout(new LogoutResponseCallback() {
                            @Override
                            public void onCompleteLogout() {
                                Log.i("KAKAO_API", "logout success");
                            }
                        });
                Intent intent = new Intent(SecondActivity.this, MainActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });

    }

    private class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
        ImageView bmImage;

        public DownloadImageTask(ImageView bmImage) {
            this.bmImage = bmImage;
        }

        protected Bitmap doInBackground(String... urls) {
            String urldisplay = urls[0];
            Bitmap mIcon11 = null;
            try {
                InputStream in = new java.net.URL(urldisplay).openStream();
                mIcon11 = BitmapFactory.decodeStream(in);
            } catch (Exception e) {
                Log.e("Error", e.getMessage());
                e.printStackTrace();
            }
            return mIcon11;
        }

        protected void onPostExecute(Bitmap result) {
            bmImage.setImageBitmap(result);
        }
    }
}