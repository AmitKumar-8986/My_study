#!/usr/bin/python3

class myTeam:

    user = ""
    team = ""

    def __init__(self, user, team):
        self.user = user
        self.team = team

    def display(self):
        print("User name is {}".format(self.user))
        print("User {} belongs to team {}".format(self.user, self.team))

obj = myTeam("Amit", "Team-A")
obj.display()
