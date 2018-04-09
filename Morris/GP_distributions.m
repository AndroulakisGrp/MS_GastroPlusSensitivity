[Distribution names]=xlsread('Physiological_bounds.xlsx')
names=names(10:end,1);
mean=Distribution(9:end,2);
SD=Distribution(9:end,5);

dist=lognrnd(mean(1,1),SD(1,1),100,1)
