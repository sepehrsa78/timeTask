function tpd = expDist(mu, sampleNum, lowB, upB)

x = exprnd(mu, sampleNum, 1);
pd = fitdist(x, 'Exponential');
tpd = truncate(pd, lowB, upB);

end