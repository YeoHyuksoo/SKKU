package edu.skku.map.pp_daanawa;

import android.app.Application;
import android.content.Context;

import com.kakao.auth.IApplicationConfig;
import com.kakao.auth.KakaoAdapter;
import com.kakao.auth.KakaoSDK;

public class Daanawa extends Application {
    @Override
    public void onCreate() {
        super.onCreate();

        //SDK 초기화
        KakaoSDK.init(new KakaoAdapter() {
            @Override
            public IApplicationConfig getApplicationConfig() {
                return new IApplicationConfig() {
                    @Override
                    public Context getApplicationContext() {
                        return Daanawa.this;
                    }
                };
            }
        });
    }
}
