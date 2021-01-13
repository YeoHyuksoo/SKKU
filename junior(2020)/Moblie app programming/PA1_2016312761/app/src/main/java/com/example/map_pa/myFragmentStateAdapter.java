package com.example.map_pa;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

public class myFragmentStateAdapter extends FragmentStateAdapter{

    public myFragmentStateAdapter(@NonNull FragmentActivity fragmentActivity) {
        super(fragmentActivity);
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        switch(position){
            case 0:
                return new PersonalFragment();
            case 1:
                return new PublicFragment();

        }
        return null;
    }

    @Override
    public int getItemCount() {
        return 2;
    }
}