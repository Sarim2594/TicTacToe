#include<iostream>
#include<Windows.h>
#include<fstream>
#include<sstream>
#include<vector>
#include<conio.h>
using namespace std;
extern "C" void cpp_clrscr()
{
	system("cls");
}
extern "C" void detectKeyPress()
{
	char c = _getch();
	return;
}
extern "C" void updateFile(int win, int c)
{
	ifstream file("PlayerScore.txt");
	if (!file.is_open())
	{
		cout << "Unable to open file to read";
		return;
	}
	string line;
	vector<string> lines;
	vector<int> vals;
	while (getline(file, line))
	{
		string buffer;
		int val;
		stringstream ss(line);
		getline(ss, buffer, ':');
		ss >> val;
		lines.push_back(buffer);
		vals.push_back(val);
	}
	file.close();
	ofstream file1("PlayerScore.txt");
	if (!file1)
	{
		cout << "Unable to open file to write";
		return;
	}
	if (c == 0)
	{
		vals[win - 1]++;
		vals[3]++;
	}
	else
	{
		vals[win + 3]++;
		vals[7]++;
	}
	for (int i = 0; i < vals.size(); i++)
	{	
		file1 << lines[i] << ":" << vals[i];
		if (i != vals.size() - 1) file1 << endl;
	}
	file1.close();
	return;
}