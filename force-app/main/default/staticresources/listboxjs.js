module.exports = __NEXT_REGISTER_PAGE("/accessibility/patterns/listbox", function() {
    return {
        page: webpackJsonp([149], {
            40: function(e, t, n) {
                "use strict";
                var l = n(0)
                  , a = n.n(l);
                t.a = function(e) {
                    return a.a.createElement(a.a.Fragment, null, a.a.createElement("h2", {
                        className: "site-text-introduction"
                    }, e.patternIntro), e.children, a.a.createElement("p", {
                        className: "slds-p-top_small"
                    }, "ARIA Documentation: ", a.a.createElement("a", {
                        href: e.ariaLink
                    }, e.ariaLink)))
                }
            },
            41: function(e, t, n) {
                "use strict";
                var l = n(0)
                  , a = n.n(l);
                t.a = function(e) {
                    return a.a.createElement("div", {
                        className: "slds-m-bottom_xx-large"
                    }, a.a.createElement("h3", {
                        className: "site-text-heading--xx-large"
                    }, e.sectionName), e.children)
                }
            },
            421: function(e, t, n) {
                e.exports = n(422)
            },
            422: function(e, t, n) {
                "use strict";
                Object.defineProperty(t, "__esModule", {
                    value: !0
                }),
                n.d(t, "default", function() {
                    return E
                });
                var l = n(0)
                  , a = n.n(l)
                  , o = n(423)
                  , i = n.n(o)
                  , r = n(424)
                  , s = n.n(r)
                  , c = n(8)
                  , u = n(40)
                  , p = n(41);
                function d(e) {
                    return (d = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(e) {
                        return typeof e
                    }
                    : function(e) {
                        return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
                    }
                    )(e)
                }
                function h(e, t) {
                    for (var n = 0; n < t.length; n++) {
                        var l = t[n];
                        l.enumerable = l.enumerable || !1,
                        l.configurable = !0,
                        "value"in l && (l.writable = !0),
                        Object.defineProperty(e, l.key, l)
                    }
                }
                function m(e, t) {
                    return !t || "object" !== d(t) && "function" != typeof t ? function(e) {
                        if (void 0 === e)
                            throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
                        return e
                    }(e) : t
                }
                function f(e, t) {
                    return (f = Object.setPrototypeOf || function(e, t) {
                        return e.__proto__ = t,
                        e
                    }
                    )(e, t)
                }
                var E = function(e) {
                    function t() {
                        return function(e, t) {
                            if (!(e instanceof t))
                                throw new TypeError("Cannot call a class as a function")
                        }(this, t),
                        m(this, (t.__proto__ || Object.getPrototypeOf(t)).apply(this, arguments))
                    }
                    var n, l, o;
                    return function(e, t) {
                        if ("function" != typeof t && null !== t)
                            throw new TypeError("Super expression must either be null or a function");
                        e.prototype = Object.create(t && t.prototype, {
                            constructor: {
                                value: e,
                                writable: !0,
                                configurable: !0
                            }
                        }),
                        t && f(e, t)
                    }(t, a.a.Component),
                    n = t,
                    (l = [{
                        key: "render",
                        value: function() {
                            return a.a.createElement(c.a, {
                                anchorTitle: "Listbox Pattern",
                                hasLongFormContent: !0
                            }, a.a.createElement(u.a, {
                                ariaLink: "http://w3c.github.io/aria-practices/#Listbox",
                                patternIntro: "A listbox provides a way to select or reorder options in a predefined list and a selected option can then be made to perform a single action."
                            }, a.a.createElement(p.a, {
                                sectionName: "Behavior"
                            }, a.a.createElement("ul", null, a.a.createElement("li", null, "Listboxes have options that can be selected, reordered and made to perform an action"), a.a.createElement("li", null, "Options themselves ", a.a.createElement("strong", null, "cannot contain"), " any interactive elements. For example, there cannot be a button, link or input within an option"), a.a.createElement("li", null, "Option names are flattened strings and", " ", a.a.createElement("strong", null, "should not"), " contain any formatting, semantics or hierarchy that is a requirement for understanding the options meaning"), a.a.createElement("li", null, "Options ", a.a.createElement("strong", null, "cannot"), " be required"), a.a.createElement("li", null, "Listboxes can be disabled, where each option is not selectable"), a.a.createElement("li", null, "Individual options can also be disabled"), a.a.createElement("li", null, "Listbox options can be grouped, with a label for each group")), a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Keyboard Interaction"), a.a.createElement("h5", {
                                className: "site-text-heading--medium"
                            }, "Single Select Listbox"), a.a.createElement("div", {
                                className: "site-a11y-component"
                            }, a.a.createElement(i.a, {
                                ariaLabel: "single select listbox"
                            }, a.a.createElement(s.a, {
                                name: "Option 1"
                            }), a.a.createElement(s.a, {
                                name: "Option 2"
                            }), a.a.createElement(s.a, {
                                name: "Option 3"
                            }), a.a.createElement(s.a, {
                                name: "Option 4"
                            }))), a.a.createElement("ul", null, a.a.createElement("li", null, "A listbox should act as a single tab stop, in that a user should be able to press the tab key once to leave the control"), a.a.createElement("li", null, "Only one option should be focusable in the list. That option should be the most recently selected option. By default that is the first option in the list"), a.a.createElement("li", null, a.a.createElement("code", null, "Up"), " and ", a.a.createElement("code", null, "Down"), " arrows: move", " ", a.a.createElement("strong", null, "focus and selection"), " to the previous/next option"), a.a.createElement("li", null, "Arrow navigation should wrap within the list when at the first or last option, unless you are using lazy loading or infinite scrolling techniques"), a.a.createElement("li", null, "Recommended if more than 5 options:", a.a.createElement("ul", null, a.a.createElement("li", null, a.a.createElement("code", null, "Home"), " and ", a.a.createElement("code", null, "End"), " should move focus to the first/last option"), a.a.createElement("li", null, "Type-ahead:", a.a.createElement("ul", null, a.a.createElement("li", null, "Type a character: focus moves to the next option that starts with the character"), a.a.createElement("li", null, "Type multiple characters in rapid succession: focus moves to the next option that starts with the string of characters")))))), a.a.createElement("h5", {
                                className: "site-text-heading--medium"
                            }, "Horizontally Orientated Listbox"), a.a.createElement("div", {
                                className: "site-a11y-component"
                            }, a.a.createElement(i.a, {
                                ariaLabel: "horizontal single select listbox",
                                horizontalClass: "slds-size_1-of-4",
                                isHorizontal: !0
                            }, a.a.createElement(s.a, {
                                name: "Option 1"
                            }), a.a.createElement(s.a, {
                                name: "Option 2"
                            }), a.a.createElement(s.a, {
                                name: "Option 3"
                            }), a.a.createElement(s.a, {
                                name: "Option 4"
                            }))), a.a.createElement("p", null, "A horizontally orientated Listbox should follow all the same keyboard interaction as Single Select, with the addition of:"), a.a.createElement("ul", null, a.a.createElement("li", null, a.a.createElement("code", null, "Right"), " arrow: behaves the same as the", " ", a.a.createElement("code", null, "Down"), " arrow, both keys should navigate down the list"), a.a.createElement("li", null, a.a.createElement("code", null, "Left"), " arrow: behaves the same as the ", a.a.createElement("code", null, "Up"), " ", "arrow, both keys should navigate up the list")), a.a.createElement("h5", {
                                className: "site-text-heading--medium"
                            }, "Multi Select Listbox"), a.a.createElement("div", {
                                className: "site-a11y-component"
                            }, a.a.createElement(i.a, {
                                ariaLabel: "multi select listbox",
                                hasMulti: !0
                            }, a.a.createElement(s.a, {
                                name: "Option 1"
                            }), a.a.createElement(s.a, {
                                name: "Option 2"
                            }), a.a.createElement(s.a, {
                                name: "Option 3"
                            }), a.a.createElement(s.a, {
                                name: "Option 4"
                            }))), a.a.createElement("p", null, "A Multi Select Listbox should follow all the same keyboard interaction as Single Select, with the addition of:"), a.a.createElement("ul", null, a.a.createElement("li", null, a.a.createElement("code", null, "Shift + Up"), " and ", a.a.createElement("code", null, "Shift + Down"), ": moves focus and selects additional, consecutive options"), a.a.createElement("li", null, a.a.createElement("code", null, "Control + Up"), " and ", a.a.createElement("code", null, "Control + Down"), ": moves focus only"), a.a.createElement("li", null, a.a.createElement("code", null, "Control + A"), ": selects/deselects all the options in the list"), a.a.createElement("li", null, "Recommended", a.a.createElement("ul", null, a.a.createElement("li", null, a.a.createElement("code", null, "Control + Shift + Home/End"), ": Selects the focused option and all options to the first/last option")))), a.a.createElement("h5", {
                                className: "site-text-heading--medium"
                            }, "Re-orderable Listbox"), a.a.createElement("div", {
                                className: "site-a11y-component"
                            }, a.a.createElement(i.a, {
                                ariaLabel: "drag and drop single select listbox",
                                hasDragDrop: !0
                            }, a.a.createElement(s.a, {
                                name: "Option 1"
                            }), a.a.createElement(s.a, {
                                name: "Option 2"
                            }), a.a.createElement(s.a, {
                                name: "Option 3"
                            }), a.a.createElement(s.a, {
                                name: "Option 4"
                            }))), a.a.createElement("p", null, "A Re-orderable Listbox should follow all the same keyboard interaction as Single Select, and optionally the Multi Select Listboxes, with the addition of"), a.a.createElement("ul", null, a.a.createElement("li", null, a.a.createElement("code", null, "Space"), ": toggles ", a.a.createElement("code", null, "Drag and Drop Mode"), ":", a.a.createElement("ul", null, a.a.createElement("li", null, "If not in ", a.a.createElement("code", null, "Drag and Drop Mode"), ": space grabs the selected option(s)"), a.a.createElement("li", null, "If in ", a.a.createElement("code", null, "Drag and Drop Mode"), ": space drops the option(s) at their current position"))), a.a.createElement("li", null, a.a.createElement("code", null, "Up"), " and ", a.a.createElement("code", null, "Down"), ": if in", " ", a.a.createElement("code", null, "Drag and Drop Mode"), ", move the selected options within the list"))), a.a.createElement(p.a, {
                                sectionName: "Markup"
                            }, a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "All Listbox Variants"), a.a.createElement("h5", {
                                className: "site-text-heading--medium"
                            }, "Listbox container"), a.a.createElement("p", null, "For demo purposes we use an Unordered List", " ", a.a.createElement("code", null, "<ul />"), " as the root container element."), a.a.createElement("ul", null, a.a.createElement("li", null, "The root node needs ", a.a.createElement("code", null, 'role="listbox"')), a.a.createElement("li", null, "The listbox should be labelled. This can be with", " ", a.a.createElement("code", null, 'aria-label="Label name"'), " or", " ", a.a.createElement("code", null, "aria-labelledby"), ", which points to a visible label")), a.a.createElement("h5", {
                                className: "site-text-heading--medium"
                            }, "Option Element"), a.a.createElement("p", null, "For demo purposes we use List Items ", a.a.createElement("code", null, "<li />"), " as a Listbox option."), a.a.createElement("ul", null, a.a.createElement("li", null, "Element needs ", a.a.createElement("code", null, 'role="option"')), a.a.createElement("li", null, a.a.createElement("code", null, "Option"), "s must be direct descendants of the", " ", a.a.createElement("code", null, "Listbox"), ".", a.a.createElement("ul", null, a.a.createElement("li", null, "When using a markup pattern like", " ", a.a.createElement("code", null, 'ul[role="listbox"] > li > a[role="option"]'), ", where the anchor element is the clickable", " ", a.a.createElement("code", null, "option"), ", you should add", " ", a.a.createElement("code", null, 'role="presentation"'), " to the ", a.a.createElement("code", null, "li"), ". This will cause assistive technology to only see a", " ", a.a.createElement("code", null, 'ul[role="listbox"] > a[role="option"]'), " direct descendant relationship"))), a.a.createElement("li", null, a.a.createElement("code", null, 'aria-selected="true"'), " is set on the", " ", a.a.createElement("code", null, "option"), " that is currently selected and in focus", a.a.createElement("ul", null, a.a.createElement("li", null, "Single select Listboxes only require", " ", a.a.createElement("code", null, "aria-selected"), " to be set on a single", " ", a.a.createElement("code", null, "option"), ". It ", a.a.createElement("strong", null, "should not"), " be set on other ", a.a.createElement("code", null, "options")))), a.a.createElement("li", null, a.a.createElement("code", null, "tabindex=0"), " should be set on the only focusable", " ", a.a.createElement("code", null, "option"), " in the listbox and should move with user selection.")), a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Horizontally Oriented Listbox"), a.a.createElement("p", null, "Requires all the same markup as related vertically oriented listbox, with the addition of:"), a.a.createElement("ul", null, a.a.createElement("li", null, "The ", a.a.createElement("code", null, "listbox"), " element should have", " ", a.a.createElement("code", null, 'aria-orientation="horizontal"'), " applied")), a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Multi Select Listbox"), a.a.createElement("p", null, "Requires all the same markup as the single select, with the addition of:"), a.a.createElement("ul", null, a.a.createElement("li", null, "The ", a.a.createElement("code", null, "listbox"), " element also needs", " ", a.a.createElement("code", null, 'aria-multiselectable="true"')), a.a.createElement("li", null, "Each ", a.a.createElement("code", null, "option"), " should now have", " ", a.a.createElement("code", null, "aria-selected"), " applied, which defaults to", " ", a.a.createElement("code", null, "false"), ". Only selected ", a.a.createElement("code", null, "option"), "s should be set to ", a.a.createElement("code", null, "true"))), a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Re-orderable Listbox"), a.a.createElement("p", null, "Requires all the same markup as the single select listbox and optionally all of the multi select listbox markup, with the addition of:"), a.a.createElement("ul", null, a.a.createElement("li", null, "Should have ", a.a.createElement("code", null, "aria-describedby"), " on the", " ", a.a.createElement("code", null, "listbox"), " set to the id of an element that contains instructions on how the drag and drop works (which can be visually hidden)"), a.a.createElement("li", null, "Should have an element separate from the unordered list:", a.a.createElement("ul", null, a.a.createElement("li", null, "with the attribute ", a.a.createElement("code", null, 'aria-live="assertive"')), a.a.createElement("li", null, 'that contains the status of the elements being dragged. For example: "Element 1 grabbed. Current position 1 of 4", "Element 1 moved, new positon 2 of 4", and "Element 1 dropped, final position 2 of 4".')))), a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Recommended for Long Lists"), a.a.createElement("p", null, "If the complete list of options is not currently visible, but the size of the option set is known (for example, if using lazy loading) each list element needs:"), a.a.createElement("ul", null, a.a.createElement("li", null, a.a.createElement("code", null, "aria-setsize"), " set to the length of the list"), a.a.createElement("li", null, a.a.createElement("code", null, "aria-posinset"), " set to the element's position in the list"))), a.a.createElement(p.a, {
                                sectionName: "References"
                            }, a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Usage in SLDS"), a.a.createElement("ul", {
                                className: "slds-list_dotted"
                            }, a.a.createElement("li", null, a.a.createElement("a", {
                                href: "/components/combobox"
                            }, "Combobox"), " (Single and Multi Select)"), a.a.createElement("li", null, a.a.createElement("a", {
                                href: "/components/dueling-picklist"
                            }, "Dueling Picklist"), " ", "(Single and Multi Select, Re-orderable)"), a.a.createElement("li", null, a.a.createElement("a", {
                                href: "/components/pills"
                            }, "Listbox of Pills"), " (Multi Select)"), a.a.createElement("li", null, a.a.createElement("a", {
                                href: "/components/lookups"
                            }, "Lookups"), " (Single Select)"), a.a.createElement("li", null, a.a.createElement("a", {
                                href: "/components/path"
                            }, "Path"), " (Horizontal Single Select)"), a.a.createElement("li", null, a.a.createElement("a", {
                                href: "/components/picklist"
                            }, "Picklist"), " (Single and Multi Select)")), a.a.createElement("h4", {
                                className: "site-text-heading--large"
                            }, "Usage in Traditional Software Applications"), a.a.createElement("ul", null, a.a.createElement("li", null, "Windows:", " ", a.a.createElement("a", {
                                href: "https://docs.microsoft.com/en-us/windows/uwp/controls-and-patterns/lists#list-boxes"
                            }, "List Boxes"), " ", "(Single and Multi Select)"), a.a.createElement("li", null, "Windows:", " ", a.a.createElement("a", {
                                href: "https://docs.microsoft.com/en-us/windows/uwp/controls-and-patterns/lists#list-views"
                            }, "List Views"), " ", "(Re-orderable)")))))
                        }
                    }]) && h(n.prototype, l),
                    o && h(n, o),
                    t
                }()
            },
            423: function(e, t, n) {
                "use strict";
                function l(e) {
                    return (l = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(e) {
                        return typeof e
                    }
                    : function(e) {
                        return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
                    }
                    )(e)
                }
                t.__esModule = !0;
                var a = n(0)
                  , o = s(a)
                  , i = s(n(2))
                  , r = s(n(1));
                function s(e) {
                    return e && e.__esModule ? e : {
                        default: e
                    }
                }
                r.default.string,
                r.default.bool,
                r.default.bool,
                r.default.string,
                r.default.bool;
                var c = function(e) {
                    function t() {
                        !function(e, t) {
                            if (!(e instanceof t))
                                throw new TypeError("Cannot call a class as a function")
                        }(this, t);
                        var n = function(e, t) {
                            if (!e)
                                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
                            return !t || "object" !== l(t) && "function" != typeof t ? e : t
                        }(this, e.call(this));
                        return n.state = {
                            ariaLiveText: "",
                            focusedOption: 0,
                            inDragdropMode: !1,
                            listOptions: null,
                            selectedOptions: [0]
                        },
                        n.handleClick = n.handleClick.bind(n),
                        n.handleDrag = n.handleDrag.bind(n),
                        n.handleDragOver = n.handleDragOver.bind(n),
                        n.handleDrop = n.handleDrop.bind(n),
                        n.handleKeyDown = n.handleKeyDown.bind(n),
                        n
                    }
                    return function(e, t) {
                        if ("function" != typeof t && null !== t)
                            throw new TypeError("Super expression must either be null or a function, not " + l(t));
                        e.prototype = Object.create(t && t.prototype, {
                            constructor: {
                                value: e,
                                enumerable: !1,
                                writable: !0,
                                configurable: !0
                            }
                        }),
                        t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t)
                    }(t, e),
                    t.prototype.componentDidMount = function() {
                        this.setState({
                            listOptions: this.props.children
                        })
                    }
                    ,
                    t.prototype.findNewOption = function(e, t) {
                        var n = e;
                        return e < this.props.children.length - 1 && t ? n += 1 : e === this.props.children.length - 1 && t ? n = 0 : e > 0 && !t ? n -= 1 : 0 !== e || t || (n = this.props.children.length - 1),
                        n
                    }
                    ,
                    t.prototype.handleClick = function(e) {
                        var t = parseInt(e.target.id, 10);
                        if (e.preventDefault(),
                        this.props.hasMulti && e.shiftKey) {
                            var n = []
                              , l = []
                              , a = this.state.selectedOptions[this.state.selectedOptions.length - 1];
                            if (t > a)
                                for (var o = a; o <= t; o++)
                                    l.push(o);
                            else
                                for (o = t; o <= a; o++)
                                    l.push(o);
                            for (o = 0; o < l.length; o++)
                                n = this.updateArray(l[o], n)
                        } else if (this.props.hasMulti && (e.ctrlKey || e.metaKey))
                            n = this.updateArray(t, this.state.selectedOptions);
                        else
                            n = [t];
                        this.setState({
                            focusedOption: t,
                            selectedOptions: n
                        })
                    }
                    ,
                    t.prototype.handleDrag = function(e) {
                        e.preventDefault();
                        var t = parseInt(e.target.id, 10);
                        this.setState({
                            focusedOption: t,
                            selectedOptions: [t]
                        })
                    }
                    ,
                    t.prototype.handleDragDropKeyDown = function(e) {
                        var t = parseInt(e.target.id, 10);
                        if ("ArrowDown" === e.key || "ArrowUp" === e.key)
                            if (this.state.inDragdropMode) {
                                e.preventDefault();
                                var n = void 0;
                                n = "ArrowDown" === e.key;
                                var l = this.state.selectedOptions[0]
                                  , a = this.findNewOption(t, n);
                                this.handleDragStateChange(l, a);
                                var o = this.state.listOptions[l].props.name
                                  , i = this.updateAssistiveText(o, a, !1, !0);
                                this.setState({
                                    ariaLiveText: i
                                })
                            } else
                                this.handleSingleSelectKeyDown(e);
                        else if (" " === e.key) {
                            e.preventDefault();
                            o = this.state.listOptions[t].props.name;
                            if (this.state.inDragdropMode) {
                                l = this.state.selectedOptions[0];
                                var r = this.state.focusedOption;
                                this.handleDragStateChange(l, r),
                                o = this.state.listOptions[l].props.name
                            }
                            i = this.updateAssistiveText(o, this.state.focusedOption, this.state.inDragdropMode, !1);
                            this.setState(function(e) {
                                return {
                                    ariaLiveText: i,
                                    inDragdropMode: !e.inDragdropMode
                                }
                            })
                        }
                    }
                    ,
                    t.prototype.handleDragOver = function(e) {
                        e.preventDefault()
                    }
                    ,
                    t.prototype.handleDragStateChange = function(e, t) {
                        var n = this.state.listOptions.slice()
                          , l = this.state.listOptions[e];
                        n.splice(e, 1),
                        n.splice(t, 0, l);
                        var a = [t];
                        this.setState({
                            focusedOption: t,
                            listOptions: n,
                            selectedOptions: a
                        })
                    }
                    ,
                    t.prototype.handleDrop = function(e) {
                        e.preventDefault();
                        var t = this.state.selectedOptions[0]
                          , n = parseInt(e.target.id, 10);
                        this.handleDragStateChange(t, n)
                    }
                    ,
                    t.prototype.handleKeyDown = function(e) {
                        this.props.hasMulti ? this.handleMultiSelectKeyDown(e) : this.props.hasDragDrop ? this.handleDragDropKeyDown(e) : this.handleSingleSelectKeyDown(e)
                    }
                    ,
                    t.prototype.handleMultiSelectKeyDown = function(e) {
                        var t = parseInt(e.target.id, 10);
                        if ("ArrowDown" === e.key || "ArrowUp" === e.key) {
                            e.preventDefault();
                            var n = void 0;
                            n = "ArrowDown" === e.key;
                            var l = this.findNewOption(t, n);
                            if (e.shiftKey) {
                                var a = this.updateArray(l, this.state.selectedOptions);
                                this.setState({
                                    focusedOption: l,
                                    selectedOptions: a,
                                    ariaLiveText: null
                                })
                            } else
                                e.ctrlKey || e.metaKey ? this.setState({
                                    focusedOption: l
                                }) : this.handleSingleSelectKeyDown(e)
                        } else if (" " === e.key && e.ctrlKey) {
                            e.preventDefault();
                            var o = this.updateArray(t, this.state.selectedOptions);
                            this.setState({
                                selectedOptions: o
                            })
                        } else
                            "a" === e.key && e.ctrlKey && this.handleSelectAll()
                    }
                    ,
                    t.prototype.handleSelectAll = function() {
                        var e = [0, 1, 2, 3]
                          , t = "Selected all elements";
                        4 === this.state.selectedOptions.length && (e = [this.state.focusedOption],
                        t = "Deselected all elements"),
                        this.setState({
                            selectedOptions: e,
                            ariaLiveText: t
                        })
                    }
                    ,
                    t.prototype.handleSingleSelectKeyDown = function(e) {
                        var t = parseInt(e.target.id, 10);
                        if ("ArrowDown" === e.key || "ArrowRight" === e.key && this.props.isHorizontal) {
                            e.preventDefault();
                            var n = this.findNewOption(t, !0);
                            this.setState({
                                focusedOption: n,
                                selectedOptions: [n],
                                ariaLiveText: null
                            })
                        } else if ("ArrowUp" === e.key || "ArrowLeft" === e.key && this.props.isHorizontal) {
                            e.preventDefault();
                            var l = this.findNewOption(t, !1);
                            this.setState({
                                focusedOption: l,
                                selectedOptions: [l],
                                ariaLiveText: null
                            })
                        }
                    }
                    ,
                    t.prototype.renderListboxOptions = function() {
                        var e = this;
                        return o.default.Children.map(this.state.listOptions, function(t, n) {
                            return o.default.cloneElement(t, {
                                horizontalClass: e.props.horizontalClass,
                                id: n.toString(),
                                isDraggable: e.props.hasDragDrop,
                                isFocused: e.state.focusedOption === n,
                                isHorizontal: e.props.isHorizontal,
                                isSelected: e.state.selectedOptions.indexOf(n) > -1,
                                onClick: e.handleClick,
                                onDrag: e.handleDrag,
                                onDragOver: e.handleDragOver,
                                onDrop: e.handleDrop
                            })
                        })
                    }
                    ,
                    t.prototype.updateArray = function(e, t) {
                        var n = t.slice();
                        return -1 === t.indexOf(e) ? n.push(e) : n.splice(t.indexOf(e), 1),
                        n
                    }
                    ,
                    t.prototype.updateAssistiveText = function(e, t, n, l) {
                        var a = e;
                        return n || l || (a += " grabbed, current "),
                        !n && l && (a += " moved, new "),
                        n && (a += " dropped, final "),
                        a += "position " + (t + 1) + " of " + this.props.children.length
                    }
                    ,
                    t.prototype.render = function() {
                        var e = this;
                        return o.default.createElement("div", null, this.props.hasDragDrop || this.props.hasMulti ? o.default.createElement(function() {
                            return o.default.createElement("div", null, e.props.hasDragDrop ? o.default.createElement("div", {
                                id: "instructions",
                                className: "slds-assistive-text"
                            }, "Press space bar to toggle drag drop mode, use arrow keys to move selected elements.") : null, e.props.hasDragDrop || e.props.hasMulti ? o.default.createElement("div", {
                                "aria-live": "assertive",
                                className: "slds-assistive-text assistiveText"
                            }, e.state.ariaLiveText) : null)
                        }, null) : null, o.default.createElement("ul", {
                            "aria-describedby": this.props.hasDragDrop ? "instructions" : null,
                            "aria-label": this.props.ariaLabel,
                            "aria-multiselectable": !!this.props.hasMulti || null,
                            "aria-orientation": this.props.isHorizontal ? "horizontal" : null,
                            className: (0,
                            i.default)("slds-border_top", "slds-border_right", "slds-border_bottom", "slds-border_left", {
                                "slds-list_horizontal": this.props.isHorizontal
                            }),
                            onKeyDown: this.handleKeyDown,
                            role: "listbox"
                        }, this.renderListboxOptions()))
                    }
                    ,
                    t
                }(a.Component);
                c.propTypes = {},
                t.default = c,
                e.exports = t.default
            },
            424: function(e, t, n) {
                "use strict";
                function l(e) {
                    return (l = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(e) {
                        return typeof e
                    }
                    : function(e) {
                        return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
                    }
                    )(e)
                }
                t.__esModule = !0;
                var a = n(0)
                  , o = s(a)
                  , i = s(n(2))
                  , r = s(n(1));
                function s(e) {
                    return e && e.__esModule ? e : {
                        default: e
                    }
                }
                r.default.string,
                r.default.string,
                r.default.bool,
                r.default.bool,
                r.default.bool,
                r.default.bool,
                r.default.string,
                r.default.func,
                r.default.func,
                r.default.func,
                r.default.func;
                var c = function(e) {
                    function t() {
                        return function(e, t) {
                            if (!(e instanceof t))
                                throw new TypeError("Cannot call a class as a function")
                        }(this, t),
                        function(e, t) {
                            if (!e)
                                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
                            return !t || "object" !== l(t) && "function" != typeof t ? e : t
                        }(this, e.apply(this, arguments))
                    }
                    return function(e, t) {
                        if ("function" != typeof t && null !== t)
                            throw new TypeError("Super expression must either be null or a function, not " + l(t));
                        e.prototype = Object.create(t && t.prototype, {
                            constructor: {
                                value: e,
                                enumerable: !1,
                                writable: !0,
                                configurable: !0
                            }
                        }),
                        t && (Object.setPrototypeOf ? Object.setPrototypeOf(e, t) : e.__proto__ = t)
                    }(t, e),
                    t.prototype.componentDidUpdate = function() {
                        this.props.isFocused && this.listItem.focus()
                    }
                    ,
                    t.prototype.render = function() {
                        var e = this;
                        return o.default.createElement("li", {
                            "aria-selected": this.props.isSelected,
                            className: (0,
                            i.default)("slds-p-around_xx-small", this.props.horizontalClass, {
                                "slds-text-align_center": !this.props.isDraggable,
                                "slds-color__background_gray-4": this.props.isSelected
                            }),
                            draggable: !!this.props.isDraggable,
                            id: this.props.id,
                            onClick: this.props.onClick,
                            onDrag: this.props.isDraggable ? this.props.onDrag : null,
                            onDragOver: this.props.isDraggable ? this.props.onDragOver : null,
                            onDrop: this.props.isDraggable ? this.props.onDrop : null,
                            ref: function(t) {
                                e.listItem = t
                            },
                            role: "option",
                            tabIndex: this.props.isFocused ? 0 : -1
                        }, this.props.isDraggable ? o.default.createElement("span", {
                            "aria-hidden": !0,
                            className: "slds-text-heading_medium slds-p-right_xx-small"
                        }, "⋮") : null, this.props.name)
                    }
                    ,
                    t
                }(a.PureComponent);
                c.propTypes = {},
                t.default = c,
                e.exports = t.default
            }
        }, [421]).default
    }
});
