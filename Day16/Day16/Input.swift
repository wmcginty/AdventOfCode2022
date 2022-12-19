//
//  Input.swift
//  Day1
//
//  Created by Will McGinty on 12/19/22.
//

import Foundation

extension String {
    static let input = """
    Valve RU has flow rate=0; tunnels lead to valves YH, ID
    Valve QK has flow rate=24; tunnels lead to valves PQ, PP
    Valve RP has flow rate=11; tunnels lead to valves RM, BA, RI, EM
    Valve BX has flow rate=0; tunnels lead to valves ZX, VK
    Valve JL has flow rate=0; tunnels lead to valves ID, LC
    Valve DC has flow rate=25; tunnel leads to valve ST
    Valve HX has flow rate=0; tunnels lead to valves DH, FE
    Valve KJ has flow rate=0; tunnels lead to valves ZK, XN
    Valve EM has flow rate=0; tunnels lead to valves AW, RP
    Valve XN has flow rate=7; tunnels lead to valves LH, KJ, KU, AO
    Valve DH has flow rate=9; tunnels lead to valves SY, CC, QL, LH, HX
    Valve LH has flow rate=0; tunnels lead to valves XN, DH
    Valve PP has flow rate=0; tunnels lead to valves QK, TA
    Valve AO has flow rate=0; tunnels lead to valves AA, XN
    Valve SY has flow rate=0; tunnels lead to valves DH, AA
    Valve MZ has flow rate=0; tunnels lead to valves JT, PF
    Valve AA has flow rate=0; tunnels lead to valves JN, UN, WG, SY, AO
    Valve RM has flow rate=0; tunnels lead to valves XL, RP
    Valve BA has flow rate=0; tunnels lead to valves RP, YP
    Valve AD has flow rate=12; tunnels lead to valves LK, ZX, AW
    Valve ZN has flow rate=0; tunnels lead to valves EQ, HL
    Valve EX has flow rate=18; tunnel leads to valve RB
    Valve CR has flow rate=0; tunnels lead to valves TA, ST
    Valve WG has flow rate=0; tunnels lead to valves AA, TA
    Valve UN has flow rate=0; tunnels lead to valves WK, AA
    Valve VE has flow rate=0; tunnels lead to valves JA, KW
    Valve JA has flow rate=19; tunnels lead to valves PQ, VE
    Valve AW has flow rate=0; tunnels lead to valves AD, EM
    Valve XL has flow rate=0; tunnels lead to valves RM, PF
    Valve OD has flow rate=0; tunnels lead to valves VK, RI
    Valve FE has flow rate=0; tunnels lead to valves JT, HX
    Valve PQ has flow rate=0; tunnels lead to valves JA, QK
    Valve RB has flow rate=0; tunnels lead to valves CC, EX
    Valve JT has flow rate=3; tunnels lead to valves RF, MZ, ZK, FE, DD
    Valve YP has flow rate=0; tunnels lead to valves ID, BA
    Valve ID has flow rate=14; tunnels lead to valves JL, RU, YP
    Valve YH has flow rate=0; tunnels lead to valves RU, VK
    Valve TA has flow rate=21; tunnels lead to valves WG, KU, PP, RF, CR
    Valve LK has flow rate=0; tunnels lead to valves PF, AD
    Valve DD has flow rate=0; tunnels lead to valves JN, JT
    Valve HL has flow rate=0; tunnels lead to valves ZN, DW
    Valve VK has flow rate=22; tunnels lead to valves OD, KW, BX, YH
    Valve RF has flow rate=0; tunnels lead to valves JT, TA
    Valve CC has flow rate=0; tunnels lead to valves RB, DH
    Valve KW has flow rate=0; tunnels lead to valves VE, VK
    Valve PF has flow rate=10; tunnels lead to valves WK, MZ, QL, XL, LK
    Valve ZX has flow rate=0; tunnels lead to valves AD, BX
    Valve JN has flow rate=0; tunnels lead to valves DD, AA
    Valve ST has flow rate=0; tunnels lead to valves CR, DC
    Valve WK has flow rate=0; tunnels lead to valves PF, UN
    Valve DW has flow rate=13; tunnels lead to valves LC, HL
    Valve ZK has flow rate=0; tunnels lead to valves KJ, JT
    Valve QL has flow rate=0; tunnels lead to valves DH, PF
    Valve RI has flow rate=0; tunnels lead to valves OD, RP
    Valve EQ has flow rate=23; tunnel leads to valve ZN
    Valve LC has flow rate=0; tunnels lead to valves JL, DW
    Valve KU has flow rate=0; tunnels lead to valves XN, TA
    """
}
