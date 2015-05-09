//
//  ProxyingSignal.swift
//  Channel
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

public enum ProxyingSignal<T> {
	public typealias	Snapshot	=	Repository<T,S>
	public typealias	Transaction	=	CollectionTransaction<Array<T>.Index,T>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
