function [y,w] = DecisionFunction(x,model)



len = length(model.Alpha);
w = 0;

for i = 1:len

w = w + model.Alpha(i);  %���ߺ�������
end
b = -model.Bias;
y = w + b;
