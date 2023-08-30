import numpy as np

class BayesianObserver:
    def __init__(self, xSvec, xPvec, minR, maxR, nSteps, integRange):
        self.xSvec      = xSvec
        self.xPvec      = xPvec
        self.minR       = minR
        self.maxR       = maxR
        self.nSteps     = nSteps
        self.integRange = integRange

    def gaussDist(self, x, μ, σ):
        return np.exp(-((x - μ) / σ) ** 2 / 2) / np.sqrt(2 * np.pi * σ ** 2)

    def expectDist(self, x, μ, σ):
        return x * self.gaussDist(x, μ, σ)

    def trpRule(self, func, *args): # min, max, μ, σ
        ranges = np.linspace(args[0], args[1], self.nSteps)
        deltaX = (args[1] - args[0]) / self.nSteps     
        if len(args) == 4:         
            cons    = (func(args[0], args[2], args[3]) + func(args[1], args[2], args[3])) / 2
            var     = sum([func(x, args[2], args[3]) for x in ranges])  
            formula = (cons + var) * deltaX
        else:
            cons     = (func(args[0]) + func(args[1])) / 2
            var      = sum([func(x) for x in ranges])  
            formula  = (cons + var) * deltaX
        return formula 
    
    def fBLS(self, w_m):
        num   = self.trpRule(self.expectDist, self.minR, self.maxR, self.xSvec, w_m * self.xSvec)
        denom = self.trpRule(self.gaussDist, self.minR, self.maxR, self.xSvec, w_m * self.xSvec) 
        return num / denom
    
    def mrgGauss(self, x_s, x_m, w_m, x_p, x_e, w_p):
        return self.gaussDist(x_m, x_s, w_m * x_s) * self.gaussDist(x_p, x_e, w_p * x_e)
    
    def BayesianModel(self, initialValues):
        logLike = np.empty(len(self.xSvec))
        x_e     = self.fBLS(initialValues[0])
        for i, x_s in enumerate(self.xSvec):
            f = lambda x_m: self.mrgGauss(x_s, x_m, initialValues[0], self.xPvec[i], x_e[i], initialValues[1])
            logLike[i] = np.sum(np.log(self.trpRule(f, self.integRange[0], self.integRange[1])))
        return -1 * np.sum(logLike)

    def BayesSimulation(self, initialValues, sampleNum, min, max):
        data  = []
        x_e   = self.fBLS(initialValues[0])
        xPvec = np.linspace(min, max, sampleNum)
        for i, x_s in enumerate(self.xSvec):
            f = lambda x_m: self.mrgGauss(x_s, x_m, initialValues[0], xPvec, x_e[i], initialValues[1])
            likelihood = self.trpRule(f, self.integRange[0], self.integRange[1])
            likelihood /= likelihood.sum()
            dist = np.random.choice(xPvec, p=likelihood, size=10000)
            data.append(dist)
        return data