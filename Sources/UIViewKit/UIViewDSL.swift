//
//  UIViewDSL.swift
//  UIViewKit
//
//  Created by Blazej SLEBODA on 10/09/2023.
//

import UIKit

public protocol UIViewDSL { }; extension UIView: UIViewDSL { }

@MainActor
class UIViewDSLEngine {
    static let shared = UIViewDSLEngine()
    
    var defineSubviewsDepthCallCounter: Int = .zero {
        willSet {
            if newValue == .zero {
                activateAutoLayout()
            }
        }
    }
    
    var constraintsToApply: [(UIView, [NSLayoutConstraint])] = []
    
    private init() {}
    
    func activateAutoLayout() {
        constraintsToApply.forEach { view, constraints in
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(constraints)
        }
        constraintsToApply.removeAll()
    }
}

@MainActor
extension UIViewDSL where Self: UIView {

    @discardableResult
    public func ibOutlet(_ outlet: inout Self?) -> Self {
        outlet = self
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout Self) -> Self {
        outlet = self
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout Self?, @UIViewBuilder _ content: () -> [UIView]) -> Self {
        outlet = self
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout Self?, @UIViewBuilder _ content: (UIView) -> [UIView]) -> Self {
        outlet = self
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout Self, @UIViewBuilder _ content: () -> [UIView]) -> Self {
        outlet = self
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout Self, @UIViewBuilder _ content: (UIView) -> [UIView]) -> Self {
        outlet = self
        coreDefineSubviews(content)
        return self
    }

    @discardableResult
    public func ibOutlet(in outlet: inout [Self]) -> Self {
        outlet.append(self)
        return self
    }
    
    @discardableResult
    public func ibOutlet(in outlet: inout [Self], @UIViewBuilder _ content: () -> [UIView]) -> Self {
        outlet.append(self)
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func ibOutlet(in outlet: inout [Self], @UIViewBuilder _ content: (UIView) -> [UIView]) -> Self {
        outlet.append(self)
        coreDefineSubviews(content)
        return self
    }
}

@MainActor
extension UIViewDSL where Self: UIView {

    @discardableResult
    public func ibSubviews(@UIViewBuilder _ content: () -> [UIView]) -> Self {
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func ibSubviews(@UIViewBuilder _ content: (UIView) -> [UIView]) -> Self {
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func callAsFunction(@UIViewBuilder _ content: () -> [UIView]) -> Self {
        coreDefineSubviews(content)
        return self
    }
    
    @discardableResult
    public func callAsFunction(@UIViewBuilder _ content: (UIView) -> [UIView]) -> Self {
        coreDefineSubviews(content)
        return self
    }
    
    func coreDefineSubviews(@UIViewBuilder _ content: (UIView) -> [UIView]) {
        UIViewDSLEngine.shared.defineSubviewsDepthCallCounter += 1
        let subviews = content(self)
        if let stackView = self as? UIStackView {
            subviews.forEach { stackView.addArrangedSubview($0) }
        } else {
            subviews.forEach {
                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        UIViewDSLEngine.shared.defineSubviewsDepthCallCounter -= 1
    }
    
    func coreDefineSubviews(@UIViewBuilder _ content: () -> [UIView]) {
        UIViewDSLEngine.shared.defineSubviewsDepthCallCounter += 1
        let subviews = content()
        if let stackView = self as? UIStackView {
            subviews.forEach { stackView.addArrangedSubview($0) }
        } else {
            subviews.forEach {
                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        UIViewDSLEngine.shared.defineSubviewsDepthCallCounter -= 1
    }

}

extension UIViewDSL where Self: UIView {

    @MainActor
    @discardableResult
    public func ibAttributes(@NSLayoutConstraintBuilder _ block: (Self) -> [NSLayoutConstraint]) -> Self {
        UIViewDSLEngine.shared.constraintsToApply.append((self, block(self)))
        return self
    }
}

extension NSLayoutConstraint {
    
    static public func activate(@NSLayoutConstraintBuilder _ block: () -> [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(block())
    }
    
    @discardableResult
    public func ibPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout NSLayoutConstraint?) -> Self {
        outlet = self
        return self
    }
    
    @discardableResult
    public func ibOutlet(_ outlet: inout NSLayoutConstraint) -> Self {
        outlet = self
        return self
    }
}

@resultBuilder
public enum UIViewBuilder {
    
    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: UIView) -> [UIView] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [UIView]) -> [UIView] {
        expression
    }
    
    public static func buildExpression(_ expression: Void) -> [UIView] {
        []
    }
    
    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component.flatMap { $0 } ?? []
    }
    
    public static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }
    
    public static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }
}

@resultBuilder
public enum NSLayoutConstraintBuilder {
    
    public static func buildBlock(_ components: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
        components.flatMap { $0 }
    }
    
    public static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components
    }
    
    public static func buildOptional(_ component: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
        component ?? []
    }
    
    public static func buildEither(first component: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        component
    }
    
    public static func buildEither(second component: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        component
    }
    
    public static func buildExpression(_ expression: NSLayoutConstraint) -> [NSLayoutConstraint] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        expression
    }
    
    public static func buildExpression(_ expression: Void) -> [NSLayoutConstraint] {
        []
    }
}

public class HorizontalStack: UIStackView {
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(spacing: CGFloat? = nil, alignment: UIStackView.Alignment? = nil, distribution: UIStackView.Distribution? = nil) {
        self.init()
        self.axis = .horizontal
        if let alignment {
            self.alignment = alignment
        }
        if let distribution {
            self.distribution = distribution
        }
        if let spacing {
            self.spacing = spacing
        }
    }
}

public class VerticalStack: UIStackView {
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(spacing: CGFloat? = nil, alignment: UIStackView.Alignment? = nil, distribution: UIStackView.Distribution? = nil) {
        self.init()
        self.axis = .vertical
        if let alignment {
            self.alignment = alignment
        }
        if let distribution {
            self.distribution = distribution
        }
        if let spacing {
            self.spacing = spacing
        }
    }
}

extension UIStackView {

    public convenience init(axis: NSLayoutConstraint.Axis, spacing: CGFloat? = nil, alignment: UIStackView.Alignment? = nil, distribution: UIStackView.Distribution? = nil) {
        self.init()
        self.axis = axis
        if let spacing {
            self.spacing = spacing
        }
        if let alignment {
            self.alignment = alignment
        }
        if let distribution {
            self.distribution = distribution
        }
    }
}

public enum LayoutGuide {
    case view
    case viewMargins
    case viewSafeArea
}

public enum ViewAnchor {
    case left(CGFloat)
    case right(CGFloat)
    case top(CGFloat)
    case bottom(CGFloat)
    case centerX(CGFloat)
    case centerY(CGFloat)
    case leading(CGFloat)
    case trailing(CGFloat)
    case all
    
    static public var left: ViewAnchor { return .left(.zero) }
    static public var right: ViewAnchor { return .right(.zero) }
    static public var top: ViewAnchor { return .top(.zero) }
    static public var bottom: ViewAnchor { return .bottom(.zero) }
    static public var centerX: ViewAnchor { return .centerX(.zero) }
    static public var centerY: ViewAnchor { return .centerY(.zero) }
    static public var leading: ViewAnchor { return .leading(.zero) }
    static public var trailing: ViewAnchor { return .trailing(.zero) }
}

extension UIView {

    public func ibConstraints(to view: UIView, guide: LayoutGuide, anchors: ViewAnchor...) -> [NSLayoutConstraint] {
        switch guide {
        case .view:
            return applyConstraints(to: view, anchors: anchors)
        case .viewMargins:
            return applyConstraints(to: view.layoutMarginsGuide, anchors: anchors)
        case .viewSafeArea:
            return applyConstraints(to: view.safeAreaLayoutGuide, anchors: anchors)
        }
    }
    
    private func applyConstraints(to target: Any, anchors: [ViewAnchor]) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        
        for anchor in anchors {
            switch anchor {
            case .left(let value):
                constraints.append(leftAnchor.constraint(equalTo: (target as? UILayoutGuide)?.leftAnchor ?? (target as? UIView)?.leftAnchor ?? leftAnchor, constant: value))
            case .right(let value):
                constraints.append(rightAnchor.constraint(equalTo: (target as? UILayoutGuide)?.rightAnchor ?? (target as? UIView)?.rightAnchor ?? rightAnchor, constant: value))
            case .top(let value):
                constraints.append(topAnchor.constraint(equalTo: (target as? UILayoutGuide)?.topAnchor ?? (target as? UIView)?.topAnchor ?? topAnchor, constant: value))
            case .bottom(let value):
                constraints.append(bottomAnchor.constraint(equalTo: (target as? UILayoutGuide)?.bottomAnchor ?? (target as? UIView)?.bottomAnchor ?? bottomAnchor, constant: value))
            case .centerX(let value):
                constraints.append(centerXAnchor.constraint(equalTo: (target as? UILayoutGuide)?.centerXAnchor ?? (target as? UIView)?.centerXAnchor ?? centerXAnchor, constant: value))
            case .centerY(let value):
                constraints.append(centerYAnchor.constraint(equalTo: (target as? UILayoutGuide)?.centerYAnchor ?? (target as? UIView)?.centerYAnchor ?? centerYAnchor, constant: value))
            case .leading(let value):
                constraints.append(leadingAnchor.constraint(equalTo: (target as? UILayoutGuide)?.leadingAnchor ?? (target as? UIView)?.leadingAnchor ?? leadingAnchor, constant: value))
            case .trailing(let value):
                constraints.append(trailingAnchor.constraint(equalTo: (target as? UILayoutGuide)?.trailingAnchor ?? (target as? UIView)?.trailingAnchor ?? trailingAnchor, constant: value))
            case .all:
                constraints.append(contentsOf: applyConstraints(to: target, anchors: [.top, .bottom, .left, .right]))
            }
        }
        
        return constraints
    }
}
