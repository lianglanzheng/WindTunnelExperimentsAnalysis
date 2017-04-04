%{
Wind-Tunnel Experiments Laser Displacement Analysis Script
Matlab Script
Chinese/GB18030

MIT License

Copyright (c) 2017 llz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
%}

disp('风洞实验激光位移分析脚本');
disp('Copyright (c) 2017 梁岚峥');
fprintf('\n');
clear;

%% 全局参数
%{
	Global_Distance	测量点之间距离(毫米)
	Global_ChannelFactor	通道因子
	Global_Scale	缩尺比
%}
Global_Distance = 293;	% <全局>测量点之间距离(毫米)
Global_ChannelFactor = 0.05;	% <全局>通道因子
Global_Scale = 50;	% <全局>缩尺比

%% 读取数据文件列表
%{
	UserCommand	用户命令
	ListFile	列表文件(标识号)
	ListFileName	列表文件名
%}
disp('对话: 使用默认列表文件(list.txt)');
disp(' 确认输入yes，更改输入no:');
UserCommand = '';	% 初始化用户命令
while ~(strcmp(UserCommand,'yes')||strcmp(UserCommand,'no'))
	UserCommand = input('$ ','s');	% 读取用户命令
end
if strcmp(UserCommand,'yes')
	ListFileName = 'list.txt';	% 列表文件名(默认值)
else
	disp('对话: 输入列表文件名:');
	ListFileName = input('$ ','s');	% 读取列表文件名(自定义)
end
ListFile = fopen(ListFileName,'r');	% 打开列表文件
while ListFile < 0	% 打开列表文件错误处理
	fprintf('错误: 打开文件"%s"时发生了错误\n',ListFileName);
	disp('对话: 再次输入列表文件名:');
	ListFileName = input('$ ','s');
	ListFile = fopen(ListFileName,'r');
end
fprintf('\n');

%% 分析每一个数据文件
%{
	DataFile	数据文件(标识号)
	DataFileName	数据文件名
	DataFileValidCount	有效的数据文件数
	DataFileValidList	有效的数据文件列表
	Data_PageCount	数据页数
	Data_ChannelCount	通道数
	Data_ChannelFactor	通道因子
	Data_RowID	行数据标识(页码,页内数据索引)
	Data_RowValue	行原始数据(时间,各通道原始值)
	Data_RawValue	原始数据(时间,各通道原始值)
	Data_Time	时间值(秒)
	Data_Displacement	位移值(毫米)
	Data_Rotation	扭转值(度)
	All_Data_DisplacementMean	<总体>位移平均值(毫米)
	All_Data_DisplacementStD	<总体>位移标准差(毫米)
	All_Data_RotationMean	<总体>扭转平均值(毫米)
	All_Data_RotationStD	<总体>扭转标准差(毫米)
	All_Data_VerticalAmplitude	<总体>竖向振幅(毫米)
	All_Data_RotationAmplitude	<总体>扭转振幅(毫米)
%}
DataFileValidCount = 0;	% 初始化有效的数据文件数
DataFileValidList = {};	% 初始化有效的数据文件列表
All_Data_DisplacementMean = [];	% 初始化位移平均值
All_Data_DisplacementStD = [];	% 初始化位移标准差
All_Data_RotationMean = [];	% 初始化扭转平均值
All_Data_RotationStD = [];	% 初始化扭转标准差
All_Data_VerticalAmplitude = [];	% 初始化竖向振幅
All_Data_RotationAmplitude = [];	% 初始化扭转振幅
while ~feof(ListFile)
	DataFileName = fscanf(ListFile,'%s',[1]);	% 读取数据文件
	if ~strcmp(DataFileName,'')
		DataFile = fopen(DataFileName,'r');	% 打开数据文件
		if DataFile < 0
			fprintf('错误: 打开文件"%s"时发生了错误\n',DataFileName);
		else
			Data_PageCount = fscanf(DataFile,'%ld',[1]);	% 读取数据页数
			Data_ChannelCount = fscanf(DataFile,'%ld',[1]);	% 读取通道数
			if Data_ChannelCount<2
				fprintf('错误: 数据文件"%s"不满足计算要求\n',DataFileName);
			else
				DataFileValidCount = DataFileValidCount+1;
				DataFileValidList{DataFileValidCount} = DataFileName;
				fscanf(DataFile,'%f',[2]);
				fscanf(DataFile,'%d',[3]);
				Data_ChannelFactor = fscanf(DataFile,'%f',[Data_ChannelCount]);
				Data_RawValue = [];	% 初始化原始数据矩阵
				for i=1:Data_PageCount*1024
					Data_RowID = fscanf(DataFile,'%d',[2]);	% 读取页码,页内数据索引
					Data_RowValue = transpose(fscanf(DataFile,'%f',[Data_ChannelCount+1]));	% 读取当前行数据:时间,各通道原始值
					Data_RawValue = [Data_RawValue;Data_RowValue];	% 读取原始数据:时间,各通道原始值
				end
				fclose(DataFile);	% 关闭数据文件
				Data_Time = Data_RawValue(:,1);	% 计算时间值(秒)
				Data_Displacement = [];	% 初始化位移值矩阵
				for i=1:Data_ChannelCount
					Data_Displacement(:,i) = Data_RawValue(:,i+1)*Global_ChannelFactor;	% 计算位移值(毫米)
				end
				Data_Rotation = atan((Data_Displacement(:,1)-Data_Displacement(:,2))/Global_Distance)*180/pi;	% 计算扭转值(度)
				All_Data_DisplacementMean(DataFileValidCount,:) = mean(Data_Displacement(:,1:2));	% 计算位移平均值
				All_Data_DisplacementStD(DataFileValidCount,:) = std(Data_Displacement(:,1:2));	% 计算位移标准差
				All_Data_RotationMean(DataFileValidCount,:) = mean(Data_Rotation);	% 计算扭转平均值
				All_Data_RotationStD(DataFileValidCount,:) = std(Data_Rotation);	% 计算扭转标准差
				All_Data_VerticalAmplitude(DataFileValidCount,:) = All_Data_DisplacementStD(DataFileValidCount,1:2)*Global_Scale*2^0.5;	% 计算竖向振幅
				All_Data_RotationAmplitude(DataFileValidCount,:) = All_Data_RotationStD(DataFileValidCount,1)*2^0.5;	% 计算扭转振幅
			end
		end
	end
end
fclose(ListFile);	% 关闭列表文件
fprintf('\n');

%% 输出结果
fprintf('%4s%16s%16s%16s%16s\n','No.','Vertical1','Vertical2','Rotation','File');
for i=1:DataFileValidCount
	fprintf('%4d%16f%16f%16f%16s\n',i,All_Data_VerticalAmplitude(i,1:2),All_Data_RotationAmplitude(i),DataFileValidList{i});
end
fprintf('\n');
fprintf('消息: 详细情况请查看<总体>变量\n');
