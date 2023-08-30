import numpy as np
from scipy.stats import norm

class BayesianObserver:
    def __init__(self, xSvec, xPvec, minR, maxR, nSteps, integRange, fitType):
        self.xSvec      = xSvec
        self.xPvec      = xPvec
        self.minR       = minR
        self.maxR       = maxR
        self.nSteps     = nSteps
        self.integRange = integRange
        self.fitType    = fitType
    
    def gaussDist(self, x, μ, σ):
        return norm.pdf(x, μ, σ)

    def margGaussDist(self, x, μ, σ):
        return μ * self.gaussDist(x, μ, σ)
  
    def fBLS(self, x_m, w_m):
        d_ts  = np.linspace(self.minR, self.maxR, self.nSteps)
        num   = np.trapz(self.margGaussDist(x_m[:, np.newaxis], d_ts, w_m * d_ts), d_ts, axis = 1)
        denom = np.trapz(self.gaussDist(x_m[:, np.newaxis], d_ts, w_m * d_ts), d_ts, axis = 1) 
        return num / denom

    def fMAP(self, x_m, w_m):
        es = x_m * ((-1 + np.sqrt(1 + 4 * (w_m ** 2))) / (2 * (w_m ** 2)))
        es[es <= self.minR] = self.minR
        es[es >= self.maxR] = self.maxR
        return es
    
    def fMLE(self, x_m, w_m):
        es = x_m * ((-1 + np.sqrt(1 + 4 * (w_m ** 2))) / (2 * (w_m ** 2)))
        return es

    def mrgGauss(self, x_m, x_s, w_m, x_p, x_e, w_p):
        return self.gaussDist(x_m, x_s, w_m * x_s) * self.gaussDist(x_p, x_e, w_p * x_e)
    
    def BayesianModel(self, initialValues):
        d_tm    = np.linspace(self.integRange[0], self.integRange[1], self.nSteps)
        if self.fitType == 'BLS':
            f       = self.mrgGauss(d_tm, self.xSvec[:, np.newaxis], initialValues[0], self.xPvec[:, np.newaxis], self.fBLS(d_tm, initialValues[0]), initialValues[1])
        elif self.fitType == 'MLE':
            f       = self.mrgGauss(d_tm, self.xSvec[:, np.newaxis], initialValues[0], self.xPvec[:, np.newaxis], self.fMLE(d_tm, initialValues[0]), initialValues[1])
        else:
            f       = self.mrgGauss(d_tm, self.xSvec[:, np.newaxis], initialValues[0], self.xPvec[:, np.newaxis], self.fMAP(d_tm, initialValues[0]), initialValues[1])
        logLike = np.sum(np.log(np.trapz(f, d_tm, axis = 1)))
        return -1 * logLike

    def BayesSimulation(self, initialValues, simNum):
        xSvec = self.xSvec.repeat(simNum)
        x_m   = norm.rvs(xSvec, xSvec * initialValues[0])
        if self.fitType == 'BLS':
            x_e   = self.fBLS(x_m, initialValues[0])
        elif self.fitType == 'MLE':
            x_e   = self.fMLE(x_m, initialValues[0])
            x_e[x_e < 0] = 0
        else:
            x_e   = self.fMAP(x_m, initialValues[0])
            x_e[x_e <= self.minR] = self.minR
            x_e[x_e >= self.maxR] = self.maxR
        
        xPvec = norm.rvs(x_e, x_e * initialValues[1])
        return xSvec, xPvec