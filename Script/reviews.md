# Reviews
## Weak Aspects
### Review 1
- [x] 图 1 描述不清晰：The description of the channel geometry is not clear enough in Figure 1. For example, there is no driving direction of the vehicle, so the meaning of the angles in the figure cannot be clearly understood.
- [x] 增加更多对比方法：Figures 6 and 7 only show the results of the comparison between the scheme proposed in this article and the enumeration scheme. It is recommended to compare with traditional schemes or schemes proposed by others.
- [x] 测试集太小或测试太少：The data analysis in Table III mentioned that the SNR is independent with $n_L$. However, it can be seen from the data in figure 7 that as the number of antennas increases, the average SNR of received signal tends to increase slowly. I think it may be that the amount of test data is not large enough or the number of tests is not enough, which has caused this contradiction. The instability of the two curves transformation trends of the average SNR of received signal in figure 7 may be the same reason. If this is the reason, you can try it and give the simulation results again.

### Review 2
- [ ] 系统模型不够复杂：The considered system model is limited. This paper considers that TX/RX have a single RF chain only, and the case of LOS channel condition is covered.
- [x] 应该增加分层算法作为对比算法：In the simulation results, the hierarchical measurement scheme should be compared in terms of average SNR and outage prob, since it also has very low measurement overhead as the proposed FC-BET scheme.
- [ ] 穷尽算法的性能不应该是最好的：The simulation result is somewhat inadequate. If the exhaustive search algorithm requires long beam training time, it shows poor performance compared to the proposed scheme due to the high speed of vehicles (beam changes fast). I'm wondering that why the exhaustive search algorithm shows the best performance, and the proposed scheme can only reduce the measurement overhead, while achieving poor performance.

### Review 3
- [x] 图 2 描述不清晰：The description of the proposed methodology is left wanting for clarity. For instance, the scheme is apparently described in Fig. 2, but is not accompanied by relevant details in the text. Reset initial estimation, reset feature, and many other aspects of the scheme require better explanation. **考虑将 initial estimation 改成 initial measurement** 
- [ ] 应该加入非深度学习回归方法作为对比方法：As far as I can understand from the description, the main feature of the scheme is the use of an LSTM network for predicting the AoA/AoD from past data. However, in order to show the benefit of the LSTM network, the authors need to provide benchmark comparisons with other non-deep learning based regression methods - and there are tons of them out there. While the introduction seems to indicate that a comparison with "conventional schemes" will be provided, the simulation results only compare the proposed scheme performance with a fully-exhaustive scheme. 
- [x] 缺少对数据集的描述：The paper also fails to mention details of the training data from the SUMO simulator. More importantly, there are no discussions on whether training and testing was conducted on the same vehicle motion profiles or a wide variety of them. 
- [x] 图 6 的中断概率应该用非线性单位：The results in Fig. 6 are somewhat confusing. I don't understand why the authors use a linear scale to plot the probability of outage. This makes it hard to really gauge what the authors mean by "there is not any outage". A standard comparison is typically at 1% or 2% of outage.
- [x] 高平均 SNR 下的中断概率太高，而且 8 dB 并不小：I am also a bit concerned about the level of outage at the received SNRs given. So for instance, at an average received SNR of approximately 45 dB, the outage is close to 10% when the threshold is only 5 dB. Does the received SNR really have that large of a spread? Moreover, the average SNR gap is listed as being "small" at 8 dB. I would like to disagree with 8 dB being small. **把小的描述删除**
- [x] 除了预测失败，信道衰落也可能是导致中断的原因：At the end of Section III, the text seems to indicate that a new round of estimation and prediction is executed if the SNR is less than SNR_T. This seems to indicate that an outage occurs only due to the prediction mismatches, which clearly is not the case. What if it was only due to a channel fade, and not necessarily due to the prediction mismatch? **修改描述，表明并非只有预测误差会导致中断；明确噪声方差小于 -120dBW 时，没有因信道衰落导致的中断**
- [ ] 没有解释标题的快和连续：The title mentions the keywords "Fast" and "Consecutive Beam Tracking Scheme" in the title. However, it does not explicitly say anywhere in the text why the scheme is "Fast" and why it has the qualifier "Consecutive Beam Tracking"

### Review 4
- [ ] 很难看出在考虑性能和支出的情况下，哪个算法更好：The proposed beam tracking constructs the trade-off between the performance of outage probability and the computational complexity. It hardly understands the good trade-off or not.

## Recommended Changes
### Review 1
Same as Weak Aspects.

### Review 2
- [x] 加入分层算法：It is better to compare the proposed scheme with the hierarchical measurement scheme.
- [ ] 加入更多在高速车辆场景下的仿真结果：The reviewer would like to recommend adding more simulation results under the very high speed vehicle scenario.
- [ ] 应该考虑多个 RF 的模型：If possible, it would be better to include multiple-input multiple-output scenario (MIMO), which considers multiple RF chains at Tx and Rx.
  
### Review 3
Please see the weak points mentioned above. The comments described are in the order of decreasing importance. The first three I think should be incorporated in the paper with high importance.

### Review 4
- [ ] 无效意见，看错图了：In figure 7, the outage performance takes from 0.7 to 0.9. If we consider the operation of wireless communication systems, the evaluated outage is too worse. The authors should evaluate the lower outage performance.