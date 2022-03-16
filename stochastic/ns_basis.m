function [f]=ns_basis(tenor,i,q)

if(i==1)
  f= ones(size(tenor));
elseif(i==2)
  f=(1-exp(-q*tenor))./(q*tenor);
elseif(i==3)
  f=(1-exp(-q*tenor))./(q*tenor)-exp(-q*tenor);
else
  f=zeros(size(tenor));
end


