//
//  CircularScrollView.swift
//  CircularScrollingDemo
//
//  Created by JiangNan on 2018/8/2.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class CircularScrollView: UIScrollView {

    private var cardQueue: Dictionary<Int, UIView> = [:]
    private var cardOnLeft: UIView?
    private var numberOfCards = 0
    
    private var firstCardLeadingConstraint = NSLayoutConstraint()
    private var lastCardTrailingConstraint = NSLayoutConstraint()

    override func layoutSubviews() {
        super.layoutSubviews()
        insertCardIfNecessary()
    }
    
    func addCards(_ cards: [UIView]) {
        numberOfCards = cards.count
        
        for (index, card) in cards.enumerated() {
            cardQueue.updateValue(card, forKey: index)
            
            card.translatesAutoresizingMaskIntoConstraints = false
            addSubview(card)
            
            let color = (index == numberOfCards - 1) ? UIColor.red :
                (index % 2 == 0) ? UIColor.yellow : UIColor.blue
            card.backgroundColor = color
            
            setConstraints(for: card, at: index)
            cardOnLeft = card
        }
    }
    
    private func setConstraints(for card: UIView, at index: Int) {
        setStaticConstraints(for: card)
        if index == 0 {
            firstCardLeadingConstraint = card.leadingAnchor.constraint(equalTo: leadingAnchor)
            addConstraint(firstCardLeadingConstraint)
        }
        
        guard let previousCard = cardOnLeft else { return }
        addConstraint(previousCard.trailingAnchor.constraint(equalTo: card.leadingAnchor))
        
        if index == numberOfCards - 1 {
            let extraSpace = CGFloat(numberOfCards) * bounds.size.width
            lastCardTrailingConstraint = card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -extraSpace)
            addConstraint(lastCardTrailingConstraint)
        }
    }
    
    private func setStaticConstraints(for card: UIView) {
        addConstraint(card.topAnchor.constraint(equalTo: topAnchor))
        addConstraint(card.heightAnchor.constraint(equalTo: heightAnchor))
        addConstraint(card.widthAnchor.constraint(equalTo: widthAnchor))
    }
    
    private func insertCardIfNecessary() {
        guard numberOfCards >= 3 else { return }
        guard let firstCard = cardQueue[firstCardIndex()], let lastCard = cardQueue[lastCardIndex()] else { return }
        
        if contentOffset.x < firstCard.frame.minX /* scrolling over left edge */
            || contentOffset.x > lastCard.frame.minX /* scrolling over right edge */ {
            let minimumX = contentOffset.x
            let maximumX = contentOffset.x + bounds.size.width
            insertCards(from: minimumX, to: maximumX)
        }
    }
    
    // minX: the minimum X of area that is going to be visible
    // maxX: the maximum X of area that is going to be visible
    private func insertCards(from minX: CGFloat, to maxX: CGFloat) {
        guard let lastCard = cardQueue[lastCardIndex()] else { return }
        // get current edge on right
        var currentEdge = lastCard.frame.maxX
        
        //insert card on right until the last card covers the maxX
        while currentEdge < maxX {
            currentEdge = insertCardOnRight(currentEdge)
        }
        
        // get current edge on left
        currentEdge = firstCardLeadingConstraint.constant
        
        //insert card on left until the first card covers the minX
        while currentEdge > minX {
            currentEdge = insertCardOnLeft(currentEdge)
        }
        
        adjustContentOffset()
    }
    
    private func insertCardOnRight(_ rightEdge: CGFloat) -> CGFloat {
        let lastIndex = lastCardIndex()
        guard let lastCard = cardQueue[lastIndex] else { return rightEdge }
        if lastIndex == numberOfCards * 2 - 1 {
            // shift all cards to left to create more "available" slots on right
            // but it does not actually move those cards on screen. that work is done by adjustContentOffset()
            for index in (numberOfCards...lastIndex).reversed() {
                cardQueue[index - numberOfCards] = cardQueue[index]
                cardQueue.removeValue(forKey: index)
            }
        }
        
        let reusableCard = dequeueReusableCard()
        var frame = reusableCard.frame
        frame.origin.x = rightEdge
        frame.origin.y = 0
        reusableCard.frame = frame
        addSubview(reusableCard)
        
        setStaticConstraints(for: reusableCard)
        addConstraint(lastCard.trailingAnchor.constraint(equalTo: reusableCard.leadingAnchor))
        let extraSpace = contentWidth() - frame.maxX
        lastCardTrailingConstraint = reusableCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -extraSpace)
        addConstraint(lastCardTrailingConstraint)
        
        guard let firstCard = cardQueue[firstCardIndex()] else { return frame.maxX }
        firstCardLeadingConstraint = firstCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: firstCard.frame.minX)
        addConstraint(firstCardLeadingConstraint)
        
        return frame.maxX
    }
    
    private func insertCardOnLeft(_ leftEdge: CGFloat) -> CGFloat {
        let firstIndex = firstCardIndex()
        guard let firstCard = cardQueue[firstIndex] else { return leftEdge }
        
        if firstIndex == 0 {
            // shift all cards to right to create more "available" cards on left.
            // but it does not actually move those cards on screen. that work is done by adjustContentOffset()
            for index in 0..<numberOfCards {
                cardQueue[index + numberOfCards] = cardQueue[index]
                cardQueue.removeValue(forKey: index)
            }
        }
        let reusableCard = dequeueReusableCard()
        var frame = reusableCard.frame
        frame.origin.x = leftEdge - frame.size.width
        frame.origin.y = 0
        reusableCard.frame = frame
        addSubview(reusableCard)
        
        setStaticConstraints(for: reusableCard)
        addConstraint(reusableCard.trailingAnchor.constraint(equalTo: firstCard.leadingAnchor))
        firstCardLeadingConstraint = reusableCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: frame.minX)
        addConstraint(firstCardLeadingConstraint)
        
        guard let lastCard = cardQueue[lastCardIndex()] else { return frame.minX }
        let extraSpace = contentWidth() - lastCard.frame.maxX
        lastCardTrailingConstraint = lastCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -extraSpace)
        addConstraint(lastCardTrailingConstraint)
        
        return frame.minX
    }
    
    private func adjustContentOffset() {
        let currentOffset = contentOffset
        let frameWidth = bounds.size.width
        var newOffsetX: CGFloat
        let extraSpace = contentWidth() - frameWidth * CGFloat(numberOfCards)
        
        if currentOffset.x + frameWidth > contentWidth() {
            // After insert card on right, the content size of scroll view is enlarged.
            // we don't want the size to grow all the time, so reset contentOffset of scroll view and also adjust leading and trailing constraints
            // then the content size is always equal to self.contentWidth()
            newOffsetX = currentOffset.x - frameWidth * CGFloat(numberOfCards + 1)
            contentOffset.x = newOffsetX
            
            firstCardLeadingConstraint.constant = 0
            lastCardTrailingConstraint.constant = -extraSpace
        }
        
        if currentOffset.x < 0 {
            //similar situation. do not want the scroll view size to grow on left
            newOffsetX = frameWidth * CGFloat(numberOfCards  + 1) - fabs(currentOffset.x)
            contentOffset.x = newOffsetX
            
            firstCardLeadingConstraint.constant = extraSpace
            lastCardTrailingConstraint.constant = 0
        }
    }
    
    private func firstCardIndex() -> Int {
        for index in 0...(numberOfCards * 2 - 1) {
            if let _ = cardQueue[index] {
                return index
            }
        }
        assert(true, "There must be something wrong in queue!")
        return 0
    }
    
    private func lastCardIndex() -> Int {
        for index in (0...(numberOfCards * 2 - 1)).reversed() {
            if let _ = cardQueue[index] {
                return index
            }
        }
        assert(true, "There must be something wrong in queue!")
        return 0
    }
    
    private func dequeueReusableCard() -> UIView {
        let reusableCard: UIView
        let index: Int
        let firstIndex = firstCardIndex()
        let lastIndex = lastCardIndex()
        guard let firstCard = cardQueue[firstIndex], let lastCard = cardQueue[lastIndex] else { return UIView() }
        
        // clean previous constraints
        removeConstraint(firstCardLeadingConstraint)
        removeConstraint(lastCardTrailingConstraint)
        
        if contentOffset.x > lastCard.frame.minX {
            // dequeue card from first
            reusableCard = firstCard
            index = lastIndex + 1
            cardQueue.removeValue(forKey: firstIndex)
        }
        else {
            // dequeue card from tail
            reusableCard = lastCard
            index = firstIndex - 1
            cardQueue.removeValue(forKey: lastIndex)
        }
        cardQueue.updateValue(reusableCard, forKey: index)
        
        // remove it from super view to prepare for insert
        reusableCard.removeFromSuperview()
        
        return reusableCard
    }
    
    private func contentWidth() -> CGFloat {
        let number = CGFloat(numberOfCards * 2)
        return number * bounds.size.width
    }
}
