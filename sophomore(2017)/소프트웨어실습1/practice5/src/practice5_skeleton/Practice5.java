package practice5_skeleton;

public class Practice5 {
	SimpleCalculator calc = new SimpleCalculator();
	
	void scen1(){}
	void scen2(){}
	void scen3(){}
	void scen4(){}

	void print(){
		calc.print();
	}
	
	public static void main(String[] args){
		Practice5 test = new Test5();
		
		test.scen1();
		System.out.print("Result of scenario#1 : ");	
		test.print();
		
		test.scen2();
		System.out.print("Result of scenario#2 : ");	
		test.print();
		
		test.scen3();
		System.out.print("Result of scenario#3 : ");
		test.print();
		
		test.scen4();
		System.out.print("Result of scenario#4 : ");
		test.print();
	}
}




