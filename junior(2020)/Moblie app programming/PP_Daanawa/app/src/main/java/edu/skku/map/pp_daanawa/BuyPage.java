package edu.skku.map.pp_daanawa;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.kakao.kakaotalk.callback.TalkResponseCallback;
import com.kakao.kakaotalk.v2.KakaoTalkService;
import com.kakao.message.template.ButtonObject;
import com.kakao.message.template.ContentObject;
import com.kakao.message.template.FeedTemplate;
import com.kakao.message.template.LinkObject;
import com.kakao.message.template.SocialObject;
import com.kakao.message.template.TemplateParams;
import com.kakao.network.ErrorResult;
import com.kakao.usermgmt.UserManagement;
import com.kakao.usermgmt.callback.LogoutResponseCallback;

import java.text.SimpleDateFormat;
import java.util.Date;

public class BuyPage extends AppCompatActivity {

    String Username = "";
    String Total = "";
    String time = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_buy_page);

        Intent intent = getIntent();
        Username = intent.getExtras().getString("Username");
        Total = intent.getExtras().getString("Total");
        TextView nameText = (TextView) findViewById(R.id.name);
        nameText.setText(Username+"님 반갑습니다.");

        long now = System.currentTimeMillis();
        Date date = new Date(now);
        SimpleDateFormat mFormat = new SimpleDateFormat("yyyy/MM/dd");
        time = mFormat.format(date);

        Button sendbtn = (Button) findViewById(R.id.sendbtn);
        sendbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TemplateParams params = FeedTemplate
                        .newBuilder(ContentObject.newBuilder(
                                "(주) 다안나와",
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQdxK1lnvkPQF1OOBhQOknWLRQrodUwHMljnkpsWAiwZUQmv5TM&usqp=CAU",
                                //"http://mud-kage.kakao.co.kr/dn/NTmhS/btqfEUdFAUf/FjKzkZsnoeE4o19klTOVI1/openlink_640x640s.jpg",
                                LinkObject.newBuilder()
                                        .setWebUrl("https://developers.kakao.com")
                                        .setMobileWebUrl("https://developers.kakao.com")
                                        .build())
                                .setDescrption("구매 완료! 구매날짜: "+time+"\n  "+"구매자: "+Username+"님  "+"가격: "+Total+"원")
                                .build())
                        .setSocial(SocialObject.newBuilder()
                                .setLikeCount(10)
                                .setCommentCount(20)
                                .setSharedCount(30)
                                .setViewCount(40)
                                .build())
                        .addButton(new ButtonObject(
                                "웹에서 보기",
                                LinkObject.newBuilder()
                                        .setWebUrl("https://developers.kakao.com")
                                        .setMobileWebUrl("https://developers.kakao.com")
                                        .build()))
                        .addButton(new ButtonObject(
                                "앱에서 보기",
                                LinkObject.newBuilder()
                                        .setAndroidExecutionParams("key1=value1")
                                        .setIosExecutionParams("key1=value1")
                                        .build()))
                        .build();
                KakaoTalkService.getInstance()
                        .requestSendMemo(new TalkResponseCallback<Boolean>() {
                            @Override
                            public void onNotKakaoTalkUser() {
                                Log.e("KAKAO_API", "not kakao user");
                            }

                            @Override
                            public void onSessionClosed(ErrorResult errorResult) {
                                Log.e("KAKAO_API", "session being closed"+errorResult);
                            }

                            @Override
                            public void onFailure(ErrorResult errorResult) {
                                Log.e("KAKAO_API", "send fail");
                            }

                            @Override
                            public void onSuccess(Boolean result) {
                                Log.i("KAKAO_API", "send success");
                            }
                        }, params);
                Toast.makeText(getApplicationContext(), "send success! Please Check your app", Toast.LENGTH_LONG).show();
            }
        });

        Button homebtn = (Button) findViewById(R.id.homebtn);
        homebtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(BuyPage.this, SecondActivity.class);
                startActivity(intent);
            }
        });

        Button logoutbtn = (Button) findViewById(R.id.logoutbtn3);
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
                Intent intent = new Intent(BuyPage.this, MainActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });
    }
}