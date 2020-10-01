function coeff=formal_to_tf(block)
    %erase initial parenthesis
%     if block(end)==')'
%         block(end)='';
%     end
%     if block(1)=='('
%         for i=1:length(block)-1
%             block(i)=block(i+1);
%         end
%         block(end)='';
%     end
    replace(block,' ','');
%     for i=1:length(block)-1
%         if block(i)=='*' 
%             if block(i+2)=='u' && block(i-3)=='u'
%                 block(i-2:i+2)='^2   ';
%             end
%         end
%     end
    trf=str2sym([block '+1e-10']);
    syms u
    simplified=simplify(trf);    
    coeff = double(coeffs(simplified, 'All'));
    for i=1:length(coeff)
        if coeff(i)==1e-10
            coeff(i)=0;
        end
    end
end