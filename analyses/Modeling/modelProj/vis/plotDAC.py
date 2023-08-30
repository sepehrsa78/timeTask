import seaborn as sns
import numpy as np

def plotDataAcrossConds(axs, intervalTypes, ints, allConds, type, unit, xLim, yLim, colData):
    for iDist, distType in enumerate(intervalTypes):
        for iTime, timeType in enumerate(intervalTypes):
            sns.lineplot(x=np.linspace(xLim[0], xLim[1], xLim[1]), y=np.linspace(yLim[0], yLim[1], yLim[1]), linestyle="dashed", color='black', ax=axs[iDist])
            reps=allConds.loc[(allConds['distIntervalType'] == distType) & (allConds['timeIntervalType'] == timeType)]
            if type == 'Time':
                axs[iDist].errorbar(ints[iTime], np.mean(reps.RT[list(reps.index)[0]]), yerr=np.std(reps.RT[list(reps.index)[0]]), fmt='o', color=colData)
            else:
                axs[iTime].errorbar(ints[iDist], np.mean(reps.prodDist_1[list(reps.index)[0]]), yerr=np.std(reps.prodDist_1[list(reps.index)[0]]), fmt='o', color=colData)
            axs[iDist].set_xlabel(f'{type} Interval ({unit})')
            axs[iDist].set_ylabel(f'Reproduced {type} ({unit})')
            axs[iDist].set_title(f'{distType.capitalize()} {type}')
            axs[iDist].set_xticks(ints)
            axs[iDist].set_xlim(xLim)
            axs[iDist].set_ylim(yLim)






