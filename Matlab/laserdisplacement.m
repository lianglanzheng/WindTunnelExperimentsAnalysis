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

disp('�綴ʵ�鼤��λ�Ʒ����ű�');
disp('Copyright (c) 2017 ����');
fprintf('\n');
clear;

%% ȫ�ֲ���
%{
	Global_Distance	������֮�����(����)
	Global_ChannelFactor	ͨ������
	Global_Scale	���߱�
%}
Global_Distance = 293;	% <ȫ��>������֮�����(����)
Global_ChannelFactor = 0.05;	% <ȫ��>ͨ������
Global_Scale = 50;	% <ȫ��>���߱�

%% ��ȡ�����ļ��б�
%{
	UserCommand	�û�����
	ListFile	�б��ļ�(��ʶ��)
	ListFileName	�б��ļ���
%}
disp('�Ի�: ʹ��Ĭ���б��ļ�(list.txt)');
disp(' ȷ������yes����������no:');
UserCommand = '';	% ��ʼ���û�����
while ~(strcmp(UserCommand,'yes')||strcmp(UserCommand,'no'))
	UserCommand = input('$ ','s');	% ��ȡ�û�����
end
if strcmp(UserCommand,'yes')
	ListFileName = 'list.txt';	% �б��ļ���(Ĭ��ֵ)
else
	disp('�Ի�: �����б��ļ���:');
	ListFileName = input('$ ','s');	% ��ȡ�б��ļ���(�Զ���)
end
ListFile = fopen(ListFileName,'r');	% ���б��ļ�
while ListFile < 0	% ���б��ļ�������
	fprintf('����: ���ļ�"%s"ʱ�����˴���\n',ListFileName);
	disp('�Ի�: �ٴ������б��ļ���:');
	ListFileName = input('$ ','s');
	ListFile = fopen(ListFileName,'r');
end
fprintf('\n');

%% ����ÿһ�������ļ�
%{
	DataFile	�����ļ�(��ʶ��)
	DataFileName	�����ļ���
	DataFileValidCount	��Ч�������ļ���
	DataFileValidList	��Ч�������ļ��б�
	Data_PageCount	����ҳ��
	Data_ChannelCount	ͨ����
	Data_ChannelFactor	ͨ������
	Data_RowID	�����ݱ�ʶ(ҳ��,ҳ����������)
	Data_RowValue	��ԭʼ����(ʱ��,��ͨ��ԭʼֵ)
	Data_RawValue	ԭʼ����(ʱ��,��ͨ��ԭʼֵ)
	Data_Time	ʱ��ֵ(��)
	Data_Displacement	λ��ֵ(����)
	Data_Rotation	Ťתֵ(��)
	All_Data_DisplacementMean	<����>λ��ƽ��ֵ(����)
	All_Data_DisplacementStD	<����>λ�Ʊ�׼��(����)
	All_Data_RotationMean	<����>Ťתƽ��ֵ(����)
	All_Data_RotationStD	<����>Ťת��׼��(����)
	All_Data_VerticalAmplitude	<����>�������(����)
	All_Data_RotationAmplitude	<����>Ťת���(����)
%}
DataFileValidCount = 0;	% ��ʼ����Ч�������ļ���
DataFileValidList = {};	% ��ʼ����Ч�������ļ��б�
All_Data_DisplacementMean = [];	% ��ʼ��λ��ƽ��ֵ
All_Data_DisplacementStD = [];	% ��ʼ��λ�Ʊ�׼��
All_Data_RotationMean = [];	% ��ʼ��Ťתƽ��ֵ
All_Data_RotationStD = [];	% ��ʼ��Ťת��׼��
All_Data_VerticalAmplitude = [];	% ��ʼ���������
All_Data_RotationAmplitude = [];	% ��ʼ��Ťת���
while ~feof(ListFile)
	DataFileName = fscanf(ListFile,'%s',[1]);	% ��ȡ�����ļ�
	if ~strcmp(DataFileName,'')
		DataFile = fopen(DataFileName,'r');	% �������ļ�
		if DataFile < 0
			fprintf('����: ���ļ�"%s"ʱ�����˴���\n',DataFileName);
		else
			Data_PageCount = fscanf(DataFile,'%ld',[1]);	% ��ȡ����ҳ��
			Data_ChannelCount = fscanf(DataFile,'%ld',[1]);	% ��ȡͨ����
			if Data_ChannelCount<2
				fprintf('����: �����ļ�"%s"���������Ҫ��\n',DataFileName);
			else
				DataFileValidCount = DataFileValidCount+1;
				DataFileValidList{DataFileValidCount} = DataFileName;
				fscanf(DataFile,'%f',[2]);
				fscanf(DataFile,'%d',[3]);
				Data_ChannelFactor = fscanf(DataFile,'%f',[Data_ChannelCount]);
				Data_RawValue = [];	% ��ʼ��ԭʼ���ݾ���
				for i=1:Data_PageCount*1024
					Data_RowID = fscanf(DataFile,'%d',[2]);	% ��ȡҳ��,ҳ����������
					Data_RowValue = transpose(fscanf(DataFile,'%f',[Data_ChannelCount+1]));	% ��ȡ��ǰ������:ʱ��,��ͨ��ԭʼֵ
					Data_RawValue = [Data_RawValue;Data_RowValue];	% ��ȡԭʼ����:ʱ��,��ͨ��ԭʼֵ
				end
				fclose(DataFile);	% �ر������ļ�
				Data_Time = Data_RawValue(:,1);	% ����ʱ��ֵ(��)
				Data_Displacement = [];	% ��ʼ��λ��ֵ����
				for i=1:Data_ChannelCount
					Data_Displacement(:,i) = Data_RawValue(:,i+1)*Global_ChannelFactor;	% ����λ��ֵ(����)
				end
				Data_Rotation = atan((Data_Displacement(:,1)-Data_Displacement(:,2))/Global_Distance)*180/pi;	% ����Ťתֵ(��)
				All_Data_DisplacementMean(DataFileValidCount,:) = mean(Data_Displacement(:,1:2));	% ����λ��ƽ��ֵ
				All_Data_DisplacementStD(DataFileValidCount,:) = std(Data_Displacement(:,1:2));	% ����λ�Ʊ�׼��
				All_Data_RotationMean(DataFileValidCount,:) = mean(Data_Rotation);	% ����Ťתƽ��ֵ
				All_Data_RotationStD(DataFileValidCount,:) = std(Data_Rotation);	% ����Ťת��׼��
				All_Data_VerticalAmplitude(DataFileValidCount,:) = All_Data_DisplacementStD(DataFileValidCount,1:2)*Global_Scale*2^0.5;	% �����������
				All_Data_RotationAmplitude(DataFileValidCount,:) = All_Data_RotationStD(DataFileValidCount,1)*2^0.5;	% ����Ťת���
			end
		end
	end
end
fclose(ListFile);	% �ر��б��ļ�
fprintf('\n');

%% ������
fprintf('%4s%16s%16s%16s%16s\n','No.','Vertical1','Vertical2','Rotation','File');
for i=1:DataFileValidCount
	fprintf('%4d%16f%16f%16f%16s\n',i,All_Data_VerticalAmplitude(i,1:2),All_Data_RotationAmplitude(i),DataFileValidList{i});
end
fprintf('\n');
fprintf('��Ϣ: ��ϸ�����鿴<����>����\n');
