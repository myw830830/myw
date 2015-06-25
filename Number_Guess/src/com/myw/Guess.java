package com.myw;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Scanner;

public class Guess {	
	Scanner cin = new Scanner(System.in);
	
	private static int arrayRange = 10;
	private static ArrayList<Integer> aimNum = new ArrayList<Integer>();	
	private static ArrayList<Integer> guessNum = new ArrayList<Integer>();
	private static int aCount = 0;
	private static int bCount = 0;
	
	private void generateNum(){
		//Generate a new 4 digits number to guess.		
		//Initialize the ArrayList
		ArrayList<Integer> array = new ArrayList<Integer>();
		for(int i = 0; i < 10; i++)
			array.add(i);
		Random random = new Random();
		for(int i = 0; i < 4; i++){
			int singleNumIndex = random.nextInt(arrayRange--);			
			aimNum.add(array.get(singleNumIndex)); 
			array.remove(singleNumIndex);
		}
	}
	
	private boolean input(){
		String inputString = cin.nextLine();
		if(inputString.equals("cheat")){
			return true;
		}		
		int inputNum = Integer.parseInt(inputString);
		for(int i = 0; i < 4; i++){
			guessNum.add(0, inputNum%10);
			inputNum = inputNum/10;
		}
		return false;
	}
	
	private void output(){
		for(int i = 0; i < 4; i++)
			if(aimNum.get(i) == guessNum.get(i))
				aCount++;
		
		for(int i: aimNum)
			for(int j: guessNum)
				if(i == j)
					bCount++;
		
		bCount -= aCount;		
		System.out.println(aCount + "A" + bCount + "B");
		aCount = 0;
		bCount = 0;
	}
	
	private int array2Int(List<Integer> integers){
		int aimNum = 0;
		for(int i = 0; i < 4; i++){
			aimNum += integers.get(i) * Math.pow(10,3-i);
		}
		return aimNum;
	}
	
	public static void main(String...args){		
		Guess guess = new Guess();
		System.out.println("Welcome to the GuessNum game, enjoy it! ");
		guess.generateNum();
		int aimNumInt = guess.array2Int(aimNum);
				
		//Test if the guess number equals to the aim number.
		for(int i = 0; i < 10; i++){
			if(guess.input()){
				System.out.println(aimNumInt);	
				continue;
			}			
			guess.output();
			if(aimNum.equals(guessNum)){
				System.out.println("Congratulations! You made it!");
				return;
			}
			guessNum.clear();
		}		
		System.out.println("Sorry, already guessed 10 times, the correct answer is " + aimNumInt);
	}
}
