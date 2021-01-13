package edu.skku.map.map_pa;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;
public class VP2adapter extends FragmentStateAdapter {
    public VP2adapter(@NonNull FragmentActivity fragmentActivity) {
        super(fragmentActivity);
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        switch (position){
            case 0:
                return new Fragment1();
            default:
                return new Fragment2();
        }
    }

    @Override
    public int getItemCount() {
        return 2;
    }
}
