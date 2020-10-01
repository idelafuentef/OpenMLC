function coeff=formal_to_tf(block)
%     replace(block,' ','');
%     trf=str2sym([block '+0']);
%     syms u v
%     simplified=simplify(trf);  
%     %Get polynomia coefficients
%     [cuv,tuv]=(coeffs(trf,[u,v],'All'));  %coefficients of u terms
%     [cvu,tvu]=(coeffs(trf,[v,u],'All'));  %coefficients of v terms
%     cvu(end)=0;                         %only maintain one of the two constants
%     coeff=[cuv;cvu];
    
    replace(block,' ','');
    trf=str2sym([block '+0']);
    syms u
    simplified=simplify(trf);    
    coeff = double(coeffs(simplified, 'All'));
end