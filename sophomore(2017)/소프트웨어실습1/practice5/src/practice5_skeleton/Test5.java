package practice5_skeleton;

public class Test5 extends Practice5{
	public void scen1(){
		try{
			calc.reset();
			calc.add(2);
			calc.subtract(1);
		}catch(OutOfRangeException e1){
			e1.printStackTrace();
		}catch(AddZeroException e2){
			e2.printStackTrace();
		}catch(SubtractZeroException e3){
			e3.printStackTrace();
		}
	}
	public void scen2(){
		try{
			calc.reset();
			calc.add(3);
			calc.subtract(4);
			calc.subtract(1);
		}catch(OutOfRangeException e1){
			e1.printStackTrace();
		}catch(AddZeroException e2){
			e2.printStackTrace();
		}catch(SubtractZeroException e3){
			e3.printStackTrace();
		}
	}
	public void scen3(){
		try{
			calc.reset();
			calc.add(6);
			calc.subtract(1);
			calc.add(0);
			calc.add(2);
		}catch(OutOfRangeException e1){
			e1.printStackTrace();
		}catch(AddZeroException e2){
			e2.printStackTrace();
		}catch(SubtractZeroException e3){
			e3.printStackTrace();
		}
	}
	public void scen4(){
		try{
			calc.reset();
			calc.add(6);
			calc.subtract(0);
			calc.add(5);
			calc.add(2);
		}catch(OutOfRangeException e1){
			e1.printStackTrace();
		}catch(AddZeroException e2){
			e2.printStackTrace();
		}catch(SubtractZeroException e3){
			e3.printStackTrace();
		}
	}
}
