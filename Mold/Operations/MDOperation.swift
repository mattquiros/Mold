//
//  MDOperation.swift
//  Mold
//
//  Created by Matt Quiros on 01/02/2016.
//  Copyright © 2016 Matt Quiros. All rights reserved.
//

import Foundation

/**
 An `NSOperation` subclass that has callback blocks which may be invoked at different
 points of the operation's execution. An `MDOperation` is defined to be synchronous. For
 an asynchronous version, see `MDAsynchronousOperation`.
 */
open class MDOperation<ResultType>: Operation {
    
    public var runStartBlockInMainThread = true
    public var startBlock: (() -> ())?
    
    public var runReturnBlockInMainThread = true
    public var returnBlock: (() -> ())?
    
    public var runSuccessBlockInMainThread = true
    public var successBlock: ((ResultType) -> ())?
    
    public var runFailureBlockInMainThread = true
    public var failureBlock: ((Error) -> ())?
    
    /**
     Determines whether the operation should execute once it enters `main()`. This property is meant
     to be overridden so that you may decide whether to proceed with the operation based on a condition.
     The default value is `true`. Note that if you return `false`, none of the callback blocks will be
     executed.
     */
    open var shouldExecute: Bool {
        return true
    }
    
    open override func main() {
        if self.shouldExecute == false {
            return
        }
        
        self.runStartBlock()
        
        if self.isCancelled {
            return
        }
        
        do {
            let result = try self.makeResult(from: nil)
            
            if self.isCancelled {
                return
            }
            
            self.runSuccessBlock(result: result)
        } catch {
            if self.isCancelled {
                return
            }
            
            self.runFailureBlock(error: error)
        }
    }
    
    open func makeResult(from source: Any?) throws -> ResultType {
        fatalError("Unimplemented: \(#function)")
    }
    
    // MARK: Builders
    
    /// Overrides the `failureBlock` to show an error dialog in a presenting view controller when an error occurs.
    @discardableResult
    open func presentErrorDialogOnFailure(from presentingViewController: UIViewController) -> Self {
        self.failureBlock = {[unowned presentingViewController] (error) in
            MDErrorDialog.showError(error, from: presentingViewController)
        }
        return self
    }
    
    // MARK: Block runners
    
    public func runStartBlock() {
        guard let startBlock = self.startBlock
            else {
                return
        }
        
        if self.runStartBlockInMainThread == true {
            MDDispatcher.asyncRunInMainThread {
                startBlock()
            }
        } else {
            startBlock()
        }
    }
    
    public func runReturnBlock() {
        guard let returnBlock = self.returnBlock,
            
            // To run the return block, all of its dependencies must have finished already.
            self.dependencies.filter({ $0.isFinished }).count == self.dependencies.count
            else {
                return
        }
        
        if self.runReturnBlockInMainThread == true {
            MDDispatcher.asyncRunInMainThread {
                returnBlock()
            }
        } else {
            returnBlock()
        }
    }
    
    public func runSuccessBlock(result: ResultType) {
        self.runReturnBlock()
        
        guard let successBlock = self.successBlock
            else {
                return
        }
        
        if self.runSuccessBlockInMainThread == true {
            MDDispatcher.asyncRunInMainThread {
                successBlock(result)
            }
        } else {
            successBlock(result)
        }
    }
    
    public func runFailureBlock(error: Error) {
        self.runReturnBlock()
        
        guard let failureBlock = self.failureBlock
            else {
                return
        }
        
        if self.runFailureBlockInMainThread == true {
            MDDispatcher.asyncRunInMainThread {
                failureBlock(error)
            }
        } else {
            failureBlock(error)
        }
    }
    
}
