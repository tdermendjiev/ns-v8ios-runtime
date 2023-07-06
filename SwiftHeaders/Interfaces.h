
#import <Foundation/Foundation.h>






        @interface LCManager

            @property (assign) LCManager * shared;

            @property (assign) CGFloat * fontSize;

            @property (assign) BOOL isConsoleConfigured;

            @property (assign) NSString * currentText;

            @property (assign) CGSize * defaultConsoleSize;

            @property (assign) UIView * borderView;

            @property (assign) NSLayoutConstraint * lumaWidthAnchor;

            @property (assign) NSLayoutConstraint * lumaHeightAnchor;

            @property (assign) LumaView * lumaView;

            @property (assign) UIButton * unhideButton;

            @property (assign) UnknownTypeSoAddTypeAttributionToVariable * consoleSize;

            @property (assign) ConsoleViewController * consoleViewController;

            @property (assign) UIView * consoleView;

            @property (assign) InvertedTextView * consoleTextView;

            @property (assign) ConsoleMenuButton * menuButton;

            @property (assign) BOOL scrollLocked;

            @property (assign) UIImpactFeedbackGenerator * feedbackGenerator;

            @property (assign) UIPanGestureRecognizer * panRecognizer;

            @property (assign) UILongPressGestureRecognizer * longPressRecognizer;

            @property (assign) [CGPoint] * possibleEndpoints;

            @property (assign) CGPoint * initialViewLocation;

            @property (assign) BOOL isVisible;

            @property (assign) UIMenuElement * menu;

            @property (assign) BOOL grabberMode;

            @property (assign) BOOL hasShortened;

            @property (assign) BOOL isCharacterLimitDisabled;

            @property (assign) BOOL isCharacterLimitWarningDisabled;

            @property (assign) CGFloat * temporaryKeyboardHeightValueTracker;

            @property (assign) CGFloat * keyboardHeight;

            @property (assign) BOOL debugBordersEnabled;

            @property (assign) Timer * dynamicReportTimer;

            @property (assign) NSNumber * timerInvalidationCounter;

            @property (assign) BOOL showAllUserDefaultsKeys;

            @property (assign) UIViewPropertyAnimator * consolePiPPopAnimator;

            @property (assign) UUID * consolePiPPanner_frameRateRequestID;

            @property (assign) UIViewPropertyAnimator * consolePiPTouchDownAnimator;

            @property (assign) BOOL isPressed;



            //[]
- (void)configureConsole;

            //[]
- (void)configureConsoleViewController;

            //[]
- (void)snapToCachedEndpoint;

            //[MethodParameter: argumentLabel = Optional("previousSize"), name = previousSize, typeName = CGSize, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = previousSize: CGSize]
- (void)handleDeviceOrientationChange:(CGSize *) previousSize;

            //[MethodParameter: argumentLabel = nil, name = items, typeName = Any, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = _ items: Any]
- (void)print:(id) items;

            //[]
- (void)clear;

            //[]
- (void)copy;

            //[MethodParameter: argumentLabel = nil, name = notification, typeName = Notification, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = _ notification: Notification]
- (void)keyboardWillShow:(Notification *) notification;

            //[]
- (void)keyboardWillHide;

            //[]
- (void)systemReport;

            //[]
- (void)displayReport;

            //[MethodParameter: argumentLabel = Optional("requestMenuUpdate"), name = menuUpdateRequested, typeName = Bool, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = requestMenuUpdate menuUpdateRequested: Bool]
- (void)commitTextChanges:(BOOL) menuUpdateRequested;

            //[MethodParameter: argumentLabel = nil, name = string, typeName = String, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = _ string: String]
- (void)setAttributedText:(NSString *) string;

            //[]
- (UIMenu *)makeMenu;

            //[MethodParameter: argumentLabel = Optional("recognizer"), name = recognizer, typeName = UILongPressGestureRecognizer, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = recognizer: UILongPressGestureRecognizer]
- (void)longPressAction:(UILongPressGestureRecognizer *) recognizer;

            //[MethodParameter: argumentLabel = Optional("recognizer"), name = recognizer, typeName = UIPanGestureRecognizer, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = recognizer: UIPanGestureRecognizer]
- (void)consolePiPPanner:(UIPanGestureRecognizer *) recognizer;

            //[]
- (void)reassessGrabberMode;

            //[MethodParameter: argumentLabel = nil, name = gestureRecognizer, typeName = UIGestureRecognizer, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = _ gestureRecognizer: UIGestureRecognizer, MethodParameter: argumentLabel = Optional("shouldRecognizeSimultaneouslyWith"), name = otherGestureRecognizer, typeName = UIGestureRecognizer, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer]
- (BOOL)gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWith: (UIGestureRecognizer *)otherGestureRecognizer;

            //[MethodParameter: argumentLabel = Optional("recognizer"), name = recognizer, typeName = UITapStartEndGestureRecognizer, `inout` = false, isVariadic = false, typeAttributes = [:], defaultValue = nil, annotations = [:], asSource = recognizer: UITapStartEndGestureRecognizer]
- (void)consolePiPTapStartEnd:(UITapStartEndGestureRecognizer *) recognizer;




            +(instancetype)shared;

        @end









