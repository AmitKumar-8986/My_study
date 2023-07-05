#!/usr/bin/python3

class myClass:

    def __init__(self):
        print("This is instance of a class")

    def myFun(self,num):
        self.num = num
        num = num * num
        print("Value is :",num)
        print("This is object of a class")

#myClass()

a = myClass()
a.myFun(5)
