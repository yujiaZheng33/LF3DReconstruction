% Returns the number of histogram elements per column of image J.
function Jb =generate_histogram(J, ch ,Bins)

[~, row, ~] = size(J);
Jb = zeros(row,Bins,ch,'double');
for chanal = 1:ch
    for x = 1:row
        Patch = J(:,x,chanal);
        Patch=sort(Patch(:));
        x1=diff(Patch);
        x1(end+1)=1;
        x1=find(x1);
        value=Patch(x1);
        x1=[0;x1];
        Freq=diff(x1);
        if(value(1)==0)
            value(1)=[];
            Freq(1)=[];
        end
        Jb(x,value(:),chanal)=Freq(:);
    end
end

end
