import SwiftUI

struct OnboardingYourBodyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    var onFinish: (OnboardingCompletion) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let compactColumns = [
        GridItem(.adaptive(minimum: 92), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            chatPanel
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
        .animation(chatAnimation, value: viewModel.contextQuestionStep)
        .animation(chatAnimation, value: viewModel.isContextAdvancing)
        .animation(chatAnimation, value: viewModel.periodBasicsSubStep)
        .animation(chatAnimation, value: viewModel.exerciseSubStep)
        .animation(chatAnimation, value: viewModel.sleepGoalsSubStep)
        .accessibilityIdentifier("onboarding.page.2")
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                PixelVitoraScene(
                    state: headerVitoraState,
                    size: 82,
                    accessory: .none,
                    showsSparkles: true,
                    showsBaseShadow: false,
                    materialStyle: .heroCompanion
                )
                .accessibilityIdentifier("onboarding.pixelVitora.chat")

                VStack(alignment: .leading, spacing: 5) {
                    Text("了解你的身体节律")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(VitoraTheme.ColorToken.strongText)
                    Text("Vitora 会像聊天一样了解你，一步一步来。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if viewModel.contextQuestionStep != .ready {
                HStack {
                    Spacer()
                    Button {
                        viewModel.skipAllContextQuestions()
                    } label: {
                        Text("跳过，直接进入")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("onboarding.skip.all")
                }
            }
        }
    }

    // MARK: - Chat Panel

    private var chatPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            periodBasicsExchange
            periodImpactExchange
            exerciseExchange
            sleepAndGoalsExchange
            specialConditionsExchange
            readyExchange
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.52))
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.74), lineWidth: 0.8))
                .shadow(color: VitoraTheme.ColorToken.paperLiftShadow.opacity(0.08), radius: 16, x: 0, y: 8)
        )
        .accessibilityIdentifier("onboarding.chat.setup")
    }

    // MARK: - Step 1: Period Basics

    @ViewBuilder
    private var periodBasicsExchange: some View {
        if viewModel.contextQuestionStep == .periodBasics {
            periodDateMessagePair
            periodDurationMessagePair
            periodCycleLengthMessagePair
            periodFlowMessagePair
            periodCrampsMessagePair

            if viewModel.periodBasicsSubStep == .complete {
                OnboardingStepContinueButton(
                    title: "继续",
                    isDisabled: viewModel.isContextAdvancing
                ) {
                    viewModel.continueFromPeriodBasics()
                }
                .transition(answerTransition)
                .accessibilityIdentifier("onboarding.periodBasics.continue")
            }
        } else if hasCompleted(.periodBasics) {
            OnboardingChatMessageRow(text: "先聊聊你的经期吧，最近一次大概什么时候来的？")
                .accessibilityIdentifier("onboarding.question.periodBasics")
            OnboardingAnswerSummaryRow(text: periodBasicsSummary)
                .transition(answerTransition)
                .accessibilityIdentifier("onboarding.answer.periodBasics")
        }
    }

    @ViewBuilder
    private var periodDateMessagePair: some View {
        OnboardingChatMessageRow(text: "先聊聊你的经期吧，最近一次大概什么时候来的？")
            .accessibilityIdentifier("onboarding.question.periodBasics")

        if viewModel.periodBasicsSubStep == .lastPeriodDate {
            userBubble {
                periodDateSubQuestion
            }
                .transition(answerTransition)
        } else if viewModel.periodBasicsSubStep.rawValue > OnboardingViewModel.PeriodBasicsSubStep.lastPeriodDate.rawValue {
            OnboardingAnswerSummaryRow(text: lastPeriodDateAnswerSummary)
                .transition(answerTransition)
                .accessibilityIdentifier("onboarding.answer.periodDate")
        }
    }

    @ViewBuilder
    private var periodDurationMessagePair: some View {
        if viewModel.periodBasicsSubStep.rawValue >= OnboardingViewModel.PeriodBasicsSubStep.duration.rawValue {
            OnboardingChatMessageRow(text: "一般会持续几天？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.periodDuration")

            if viewModel.periodBasicsSubStep == .duration {
                userBubble {
                    periodDurationSubQuestion
                }
                    .transition(answerTransition)
            } else if viewModel.periodBasicsSubStep.rawValue > OnboardingViewModel.PeriodBasicsSubStep.duration.rawValue {
                OnboardingAnswerSummaryRow(text: periodDurationAnswerSummary)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.periodDuration")
            }
        }
    }

    @ViewBuilder
    private var periodCycleLengthMessagePair: some View {
        if viewModel.periodBasicsSubStep.rawValue >= OnboardingViewModel.PeriodBasicsSubStep.cycleLength.rawValue {
            OnboardingChatMessageRow(text: "两次经期之间大概隔多久？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.cycleLength")

            if viewModel.periodBasicsSubStep == .cycleLength {
                userBubble {
                    periodCycleLengthSubQuestion
                }
                    .transition(answerTransition)
            } else if viewModel.periodBasicsSubStep.rawValue > OnboardingViewModel.PeriodBasicsSubStep.cycleLength.rawValue {
                OnboardingAnswerSummaryRow(text: cycleLengthAnswerSummary)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.cycleLength")
            }
        }
    }

    @ViewBuilder
    private var periodFlowMessagePair: some View {
        if viewModel.periodBasicsSubStep.rawValue >= OnboardingViewModel.PeriodBasicsSubStep.flow.rawValue {
            OnboardingChatMessageRow(text: "经期量通常更接近哪一种？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.flow")

            if viewModel.periodBasicsSubStep == .flow {
                userBubble {
                    periodFlowSubQuestion
                }
                    .transition(answerTransition)
            } else if viewModel.periodBasicsSubStep.rawValue > OnboardingViewModel.PeriodBasicsSubStep.flow.rawValue {
                OnboardingAnswerSummaryRow(text: viewModel.flowAmount.map(flowTitle) ?? "暂不确定")
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.flow")
            }
        }
    }

    @ViewBuilder
    private var periodCrampsMessagePair: some View {
        if viewModel.periodBasicsSubStep.rawValue >= OnboardingViewModel.PeriodBasicsSubStep.cramps.rawValue {
            OnboardingChatMessageRow(text: "会痛经吗？我只用它来调整提醒力度。")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.cramps")

            if viewModel.periodBasicsSubStep == .cramps {
                userBubble {
                    periodCrampsSubQuestion
                }
                    .transition(answerTransition)
            } else if viewModel.periodBasicsSubStep.rawValue > OnboardingViewModel.PeriodBasicsSubStep.cramps.rawValue {
                OnboardingAnswerSummaryRow(text: dysmenorrheaTitle(viewModel.dysmenorrheaSeverity))
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.cramps")
            }
        }
    }

    @ViewBuilder
    private var periodDateSubQuestion: some View {
        if viewModel.periodBasicsSubStep == .lastPeriodDate {
            VStack(alignment: .leading, spacing: 8) {
                if !viewModel.lastPeriodDateUnsure {
                    DatePicker(
                        "上次经期",
                        selection: $viewModel.lastPeriodDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .labelsHidden()
                }

                HStack(spacing: 8) {
                    ChatChoicePill(title: "选择日期", isSelected: !viewModel.lastPeriodDateUnsure) {
                        viewModel.lastPeriodDateUnsure = false
                    }
                    .accessibilityIdentifier("onboarding.periodDate.choose")
                    ChatChoicePill(title: "不确定", isSelected: viewModel.lastPeriodDateUnsure) {
                        viewModel.choosePeriodDate(unsure: true)
                    }
                    .accessibilityIdentifier("onboarding.periodDate.unsure")
                }

                if !viewModel.lastPeriodDateUnsure {
                    OnboardingStepContinueButton(title: "确认日期", isDisabled: false) {
                        viewModel.choosePeriodDate(unsure: false)
                    }
                    .accessibilityIdentifier("onboarding.periodDate.confirm")
                }
            }
        }
    }

    @ViewBuilder
    private var periodDurationSubQuestion: some View {
        if viewModel.periodBasicsSubStep == .duration {
            VStack(alignment: .leading, spacing: 8) {
                if !viewModel.averagePeriodDurationUnsure {
                    HStack {
                        Text("\(Int(viewModel.averagePeriodDuration)) 天")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Slider(value: $viewModel.averagePeriodDuration, in: 2...10, step: 1)
                            .tint(VitoraTheme.ColorToken.actionPrimaryDeep)
                    }
                }

                HStack(spacing: 8) {
                    ChatChoicePill(title: "选择天数", isSelected: !viewModel.averagePeriodDurationUnsure) {
                        viewModel.averagePeriodDurationUnsure = false
                    }
                    .accessibilityIdentifier("onboarding.periodDuration.choose")
                    ChatChoicePill(title: "不确定", isSelected: viewModel.averagePeriodDurationUnsure) {
                        viewModel.choosePeriodDuration(unsure: true)
                    }
                    .accessibilityIdentifier("onboarding.periodDuration.unsure")
                }

                if !viewModel.averagePeriodDurationUnsure {
                    OnboardingStepContinueButton(title: "确认", isDisabled: false) {
                        viewModel.choosePeriodDuration(unsure: false)
                    }
                    .accessibilityIdentifier("onboarding.periodDuration.confirm")
                }
            }
        }
    }

    @ViewBuilder
    private var periodCycleLengthSubQuestion: some View {
        if viewModel.periodBasicsSubStep == .cycleLength {
            VStack(alignment: .leading, spacing: 8) {
                if !viewModel.averageCycleLengthUnsure {
                    HStack {
                        Text("\(Int(viewModel.averageCycleLength)) 天")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(VitoraTheme.ColorToken.strongText)
                        Slider(value: $viewModel.averageCycleLength, in: 18...45, step: 1)
                            .tint(VitoraTheme.ColorToken.actionPrimaryDeep)
                    }
                }

                HStack(spacing: 8) {
                    ChatChoicePill(title: "选择天数", isSelected: !viewModel.averageCycleLengthUnsure) {
                        viewModel.averageCycleLengthUnsure = false
                    }
                    .accessibilityIdentifier("onboarding.cycleLength.choose")
                    ChatChoicePill(title: "不确定", isSelected: viewModel.averageCycleLengthUnsure) {
                        viewModel.chooseCycleLength(unsure: true)
                    }
                    .accessibilityIdentifier("onboarding.cycleLength.unsure")
                }

                if !viewModel.averageCycleLengthUnsure {
                    OnboardingStepContinueButton(title: "确认", isDisabled: false) {
                        viewModel.chooseCycleLength(unsure: false)
                    }
                    .accessibilityIdentifier("onboarding.cycleLength.confirm")
                }
            }
        }
    }

    @ViewBuilder
    private var periodFlowSubQuestion: some View {
        if viewModel.periodBasicsSubStep == .flow {
            LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                ForEach(FlowAmount.allCases, id: \.self) { amount in
                    ChatChoicePill(title: flowTitle(amount), isSelected: viewModel.flowAmount == amount) {
                        viewModel.chooseFlowAmount(amount)
                    }
                    .accessibilityIdentifier(amount.accessibilityID)
                }
            }
        }
    }

    @ViewBuilder
    private var periodCrampsSubQuestion: some View {
        if viewModel.periodBasicsSubStep == .cramps {
            LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                ForEach(DysmenorrheaSeverity.allCases, id: \.self) { severity in
                    ChatChoicePill(title: dysmenorrheaTitle(severity), isSelected: viewModel.dysmenorrheaSeverity == severity) {
                        viewModel.chooseDysmenorrheaSeverity(severity)
                    }
                    .accessibilityIdentifier(severity.accessibilityID)
                }
            }
        }
    }

    // MARK: - Step 2: Period Impact

    @ViewBuilder
    private var periodImpactExchange: some View {
        if hasReached(.periodImpact) {
            OnboardingChatMessageRow(text: "经期的时候，哪些方面会比较受影响？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.periodImpact")

            if viewModel.contextQuestionStep == .periodImpact {
                userBubble {
                    LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                        ForEach(PeriodImpactArea.allCases, id: \.self) { area in
                            ChatChoicePill(
                                title: periodImpactTitle(area),
                                isSelected: viewModel.selectedPeriodImpacts.contains(area)
                            ) {
                                viewModel.togglePeriodImpact(area)
                            }
                            .accessibilityIdentifier(area.accessibilityID)
                        }
                    }

                    if viewModel.showsDysmenorrheaRescue {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("痛经急救提醒", isOn: $viewModel.dysmenorrheaReminderEnabled)
                                .font(.system(size: 14, weight: .semibold))
                                .tint(VitoraTheme.ColorToken.actionPrimaryDeep)
                            Text("开启后 Vitora 会在经期前提醒你准备")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(VitoraTheme.ColorToken.tertiaryText)
                        }
                        .padding(.top, 4)
                    }

                    OnboardingStepContinueButton(
                        title: "继续",
                        isDisabled: viewModel.isContextAdvancing
                    ) {
                        viewModel.continueFromPeriodImpact()
                    }
                    .accessibilityIdentifier("onboarding.periodImpact.continue")
                }
                .transition(answerTransition)
            } else if hasCompleted(.periodImpact) {
                OnboardingAnswerSummaryRow(text: periodImpactSummary)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.periodImpact")
            }
        }
    }

    // MARK: - Step 3: Exercise

    @ViewBuilder
    private var exerciseExchange: some View {
        if hasReached(.exercise) {
            OnboardingChatMessageRow(text: "平时有什么运动习惯？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.exercise")

            if viewModel.contextQuestionStep == .exercise {
                exerciseSportAnswer
                exerciseIntensityMessagePair

                if viewModel.exerciseSubStep == .complete {
                    OnboardingStepContinueButton(
                        title: "继续",
                        isDisabled: viewModel.isContextAdvancing
                    ) {
                        viewModel.continueFromExercise()
                    }
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.exercise.continue")
                }
            } else if hasCompleted(.exercise) {
                OnboardingAnswerSummaryRow(text: exerciseSummary)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.exercise")
            }
        }
    }

    @ViewBuilder
    private var exerciseSportAnswer: some View {
        if viewModel.exerciseSubStep == .sport {
            userBubble {
                LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                    ForEach([SportPreference.walking, .yoga, .running, .strength, .swimming, .dance, .cycling, .none], id: \.self) { sport in
                        ChatChoicePill(
                            title: sportTitle(sport),
                            isSelected: viewModel.selectedSports.contains(sport)
                        ) {
                            viewModel.toggleSport(sport)
                        }
                        .accessibilityIdentifier(sport.accessibilityID)
                    }
                }

                TextField("其他运动...", text: $viewModel.customExercise)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.6))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.7), lineWidth: 0.7))
                    )

                OnboardingStepContinueButton(
                    title: "继续",
                    isDisabled: viewModel.isContextAdvancing
                ) {
                    viewModel.continueFromExerciseSport()
                }
                .accessibilityIdentifier("onboarding.exercise.sport.continue")
            }
            .transition(answerTransition)
        } else if viewModel.exerciseSubStep.rawValue > OnboardingViewModel.ExerciseSubStep.sport.rawValue {
            OnboardingAnswerSummaryRow(text: exerciseSportSummary)
                .transition(answerTransition)
                .accessibilityIdentifier("onboarding.answer.exerciseSport")
        }
    }

    @ViewBuilder
    private var exerciseIntensityMessagePair: some View {
        if viewModel.exerciseSubStep.rawValue >= OnboardingViewModel.ExerciseSubStep.intensity.rawValue {
            OnboardingChatMessageRow(text: "更偏好什么训练强度？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.exerciseIntensity")

            if viewModel.exerciseSubStep == .intensity {
                userBubble {
                    LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                        ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                            ChatChoicePill(
                                title: intensityTitle(intensity),
                                isSelected: viewModel.exerciseIntensity == intensity
                            ) {
                                viewModel.chooseExerciseIntensityAndContinue(intensity)
                            }
                            .accessibilityIdentifier(intensity.accessibilityID)
                        }
                    }
                }
                .transition(answerTransition)
            } else if viewModel.exerciseSubStep.rawValue > OnboardingViewModel.ExerciseSubStep.intensity.rawValue {
                OnboardingAnswerSummaryRow(text: viewModel.exerciseIntensity.map(intensityTitle) ?? "看状态")
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.exerciseIntensity")
            }
        }
    }

    // MARK: - Step 4: Sleep & Goals

    @ViewBuilder
    private var sleepAndGoalsExchange: some View {
        if hasReached(.sleepAndGoals) {
            OnboardingChatMessageRow(text: "你更想通过 Vitora 改善什么？")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.sleepAndGoals")

            if viewModel.contextQuestionStep == .sleepAndGoals {
                goalsAnswer
                deviceMessagePair

                if viewModel.sleepGoalsSubStep == .complete {
                    OnboardingStepContinueButton(
                        title: "继续",
                        isDisabled: viewModel.isContextAdvancing
                    ) {
                        viewModel.continueFromSleepAndGoals()
                    }
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.sleepAndGoals.continue")
                }
            } else if hasCompleted(.sleepAndGoals) {
                OnboardingAnswerSummaryRow(text: goalsSummary)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.sleepAndGoals")
            }
        }
    }

    @ViewBuilder
    private var goalsAnswer: some View {
        if viewModel.sleepGoalsSubStep == .goals {
            userBubble {
                LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                    ForEach(ImprovementGoal.allCases, id: \.self) { goal in
                        ChatChoicePill(
                            title: goalTitle(goal),
                            isSelected: viewModel.selectedGoals.contains(goal)
                        ) {
                            viewModel.toggleGoal(goal)
                        }
                        .accessibilityIdentifier(goal.accessibilityID)
                    }
                }

                OnboardingStepContinueButton(
                    title: "继续",
                    isDisabled: viewModel.isContextAdvancing
                ) {
                    viewModel.continueFromGoals()
                }
                .accessibilityIdentifier("onboarding.goals.continue")
            }
            .transition(answerTransition)
        } else if viewModel.sleepGoalsSubStep.rawValue > OnboardingViewModel.SleepGoalsSubStep.goals.rawValue {
            OnboardingAnswerSummaryRow(text: goalsSummary)
                .transition(answerTransition)
                .accessibilityIdentifier("onboarding.answer.goals")
        }
    }

    @ViewBuilder
    private var deviceMessagePair: some View {
        if viewModel.sleepGoalsSubStep.rawValue >= OnboardingViewModel.SleepGoalsSubStep.device.rawValue {
            OnboardingChatMessageRow(text: "要不要绑定设备数据？跳过后仍然可以用。")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.device")

            if viewModel.sleepGoalsSubStep == .device {
                userBubble {
                    HStack(spacing: 10) {
                        DeviceBindingButton(
                            title: "绑定 Apple 健康",
                            systemImage: "heart.text.square.fill",
                            isSelected: viewModel.dataSourceAuthorization.state == .authorized
                        ) {
                            viewModel.chooseDataSourceAndContinue(.allow)
                        }
                        .accessibilityIdentifier("onboarding.healthkit.allow")

                        DeviceBindingButton(
                            title: "先跳过",
                            systemImage: "forward.fill",
                            isSelected: viewModel.dataSourceAuthorization.isLowData
                        ) {
                            viewModel.chooseDataSourceAndContinue(.skip)
                        }
                        .accessibilityIdentifier("onboarding.healthkit.skip")
                    }
                }
                .transition(answerTransition)
            } else if viewModel.sleepGoalsSubStep.rawValue > OnboardingViewModel.SleepGoalsSubStep.device.rawValue {
                OnboardingAnswerSummaryRow(text: healthKitStateText)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.device")
            }
        }
    }

    // MARK: - Step 5: Special Conditions

    @ViewBuilder
    private var specialConditionsExchange: some View {
        if hasReached(.specialConditions) {
            OnboardingChatMessageRow(text: "有没有特殊情况想提前告诉我？这样我可以更好地规避风险。")
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.specialConditions")

            if viewModel.contextQuestionStep == .specialConditions {
                userBubble {
                    LazyVGrid(columns: compactColumns, alignment: .leading, spacing: 8) {
                        ForEach(SpecialCondition.allCases, id: \.self) { condition in
                            ChatChoicePill(
                                title: conditionTitle(condition),
                                isSelected: viewModel.selectedSpecialConditions.contains(condition)
                            ) {
                                viewModel.toggleSpecialCondition(condition)
                            }
                            .accessibilityIdentifier(condition.accessibilityID)
                        }
                    }

                    TextField("其他需要注意的...", text: $viewModel.specialConditionNote)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.6))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.7), lineWidth: 0.7))
                        )

                    OnboardingStepContinueButton(
                        title: "继续",
                        isDisabled: viewModel.selectedSpecialConditions.isEmpty || viewModel.isContextAdvancing
                    ) {
                        viewModel.continueFromSpecialConditions()
                    }
                    .accessibilityIdentifier("onboarding.specialConditions.continue")
                }
                .transition(answerTransition)
            } else if hasCompleted(.specialConditions) {
                OnboardingAnswerSummaryRow(text: conditionsSummary)
                    .transition(answerTransition)
                    .accessibilityIdentifier("onboarding.answer.specialConditions")
            }
        }
    }

    // MARK: - Step 6: Ready

    @ViewBuilder
    private var readyExchange: some View {
        if viewModel.contextQuestionStep == .ready {
            OnboardingReadySummaryCard()
                .transition(questionTransition)
                .accessibilityIdentifier("onboarding.question.ready")

            OnboardingContinueButton(title: "进入 Vitora") {
                onFinish(viewModel.finish())
            }
            .transition(answerTransition)
            .accessibilityIdentifier("onboarding.yourBody.enter")
        }
    }

    // MARK: - Shared Components

    private func subQuestionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
            .padding(.top, 4)
    }

    private func userBubble<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack {
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 221 / 255, green: 250 / 255, blue: 180 / 255).opacity(0.72),
                                Color(red: 236 / 255, green: 255 / 255, blue: 228 / 255).opacity(0.66),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.76), lineWidth: 0.7))
            )
        }
    }

    // MARK: - Helpers

    private func hasReached(_ step: OnboardingViewModel.ContextQuestionStep) -> Bool {
        viewModel.contextQuestionStep.rawValue >= step.rawValue
    }

    private func hasCompleted(_ step: OnboardingViewModel.ContextQuestionStep) -> Bool {
        viewModel.contextQuestionStep.rawValue > step.rawValue
    }

    private var headerVitoraState: PixelVitoraState {
        if viewModel.isContextAdvancing { return .thinking }
        return viewModel.contextQuestionStep == .ready ? .confirming : .questioning
    }

    private var chatAnimation: Animation? {
        reduceMotion ? .easeOut(duration: 0.01) : .easeOut(duration: 0.22)
    }

    private var questionTransition: AnyTransition {
        reduceMotion ? .opacity : .offset(y: 10).combined(with: .opacity)
    }

    private var answerTransition: AnyTransition {
        reduceMotion ? .opacity : .offset(x: 12).combined(with: .opacity)
    }

    // MARK: - Summaries

    private var periodBasicsSummary: String {
        var parts: [String] = []
        if viewModel.lastPeriodDateUnsure {
            parts.append("日期不确定")
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "M月d日"
            parts.append("上次 \(fmt.string(from: viewModel.lastPeriodDate))")
        }
        if !viewModel.averagePeriodDurationUnsure { parts.append("经期\(Int(viewModel.averagePeriodDuration))天") }
        if !viewModel.averageCycleLengthUnsure { parts.append("周期\(Int(viewModel.averageCycleLength))天") }
        if let flow = viewModel.flowAmount { parts.append(flowTitle(flow)) }
        parts.append(dysmenorrheaTitle(viewModel.dysmenorrheaSeverity))
        return parts.joined(separator: " · ")
    }

    private var lastPeriodDateAnswerSummary: String {
        if viewModel.lastPeriodDateUnsure { return "不确定" }
        let fmt = DateFormatter()
        fmt.dateFormat = "M月d日"
        return fmt.string(from: viewModel.lastPeriodDate)
    }

    private var periodDurationAnswerSummary: String {
        if viewModel.averagePeriodDurationUnsure { return "不确定" }
        return "\(Int(viewModel.averagePeriodDuration)) 天"
    }

    private var cycleLengthAnswerSummary: String {
        if viewModel.averageCycleLengthUnsure { return "不确定" }
        return "\(Int(viewModel.averageCycleLength)) 天"
    }

    private var periodImpactSummary: String {
        let areas = PeriodImpactArea.allCases.filter { viewModel.selectedPeriodImpacts.contains($0) }
        let text = areas.map(periodImpactTitle).joined(separator: "、")
        return text.isEmpty ? "暂未选择" : text
    }

    private var exerciseSummary: String {
        var parts: [String] = []
        let sports = [SportPreference.walking, .yoga, .running, .strength, .swimming, .dance, .cycling].filter { viewModel.selectedSports.contains($0) }
        if !sports.isEmpty { parts.append(sports.map(sportTitle).joined(separator: "、")) }
        if !viewModel.customExercise.isEmpty { parts.append(viewModel.customExercise) }
        if let intensity = viewModel.exerciseIntensity { parts.append(intensityTitle(intensity)) }
        return parts.isEmpty ? "暂无运动习惯" : parts.joined(separator: " · ")
    }

    private var exerciseSportSummary: String {
        var parts: [String] = []
        let sports = [SportPreference.walking, .yoga, .running, .strength, .swimming, .dance, .cycling, .none].filter { viewModel.selectedSports.contains($0) }
        if !sports.isEmpty { parts.append(sports.map(sportTitle).joined(separator: "、")) }
        if !viewModel.customExercise.isEmpty { parts.append(viewModel.customExercise) }
        return parts.isEmpty ? "暂不运动" : parts.joined(separator: "、")
    }

    private var goalsSummary: String {
        let goals = ImprovementGoal.allCases.filter { viewModel.selectedGoals.contains($0) }
        let text = goals.map(goalTitle).joined(separator: "、")
        return text.isEmpty ? "暂未选择" : text
    }

    private var healthKitStateText: String {
        switch viewModel.dataSourceAuthorization.state {
        case .authorized:
            return "已选择绑定 Apple 健康"
        case .skipped:
            return "先跳过设备数据"
        case .denied:
            return "暂不授权设备数据"
        case .revoked:
            return "设备授权已关闭"
        case .notAsked:
            return "还没有选择，默认也可以直接进入。"
        }
    }

    private var conditionsSummary: String {
        let conditions = SpecialCondition.allCases.filter { viewModel.selectedSpecialConditions.contains($0) }
        return conditions.map(conditionTitle).joined(separator: "、")
    }

    // MARK: - Title Mappings

    private func flowTitle(_ flow: FlowAmount) -> String {
        switch flow {
        case .light: return "偏少"
        case .moderate: return "适中"
        case .heavy: return "偏多"
        case .varies: return "不固定"
        }
    }

    private func dysmenorrheaTitle(_ severity: DysmenorrheaSeverity) -> String {
        switch severity {
        case .none: return "不会痛经"
        case .occasional: return "偶尔轻微"
        case .frequent: return "经常"
        case .severe: return "比较严重"
        }
    }

    private func periodImpactTitle(_ area: PeriodImpactArea) -> String {
        switch area {
        case .energyDrop: return "能量下降"
        case .sleepWorse: return "睡眠变差"
        case .moodSwings: return "情绪波动"
        case .physicalPain: return "身体不适"
        case .appetiteChange: return "食欲变化"
        }
    }

    private func sportTitle(_ sport: SportPreference) -> String {
        switch sport {
        case .walking: return "散步"
        case .yoga: return "瑜伽"
        case .running: return "跑步"
        case .strength: return "力量训练"
        case .swimming: return "游泳"
        case .dance: return "舞蹈"
        case .cycling: return "骑行"
        case .none: return "暂不运动"
        }
    }

    private func intensityTitle(_ intensity: ExerciseIntensity) -> String {
        switch intensity {
        case .high: return "高强度"
        case .moderate: return "中等"
        case .light: return "轻量"
        case .flexible: return "看状态"
        }
    }

    private func goalTitle(_ goal: ImprovementGoal) -> String {
        switch goal {
        case .sleepQuality: return "睡眠质量"
        case .moodManagement: return "情绪管理"
        case .nutritionBalance: return "营养均衡"
        case .energyManagement: return "能量管理"
        case .cycleRegularity: return "周期规律"
        }
    }

    private func conditionTitle(_ condition: SpecialCondition) -> String {
        switch condition {
        case .tryingToConceive: return "备孕中"
        case .hormoneTreatment: return "激素治疗中"
        case .chronicIllness: return "有慢性病"
        case .pcos: return "多囊卵巢"
        case .endometriosis: return "子宫内膜异位"
        case .noneSpecial: return "无特殊情况"
        }
    }
}

// MARK: - Reusable Chat Components

private struct OnboardingChatMessageRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            PixelVitoraScene(
                state: .questioning,
                size: 34,
                accessory: .none,
                showsSparkles: false,
                showsBaseShadow: false,
                materialStyle: .tabFace
            )
            .frame(width: 34, height: 34)
            .accessibilityHidden(true)

            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(VitoraTheme.ColorToken.surfacePearlMain.opacity(0.88))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.78), lineWidth: 0.7))
                )
        }
    }
}

private struct OnboardingAnswerSummaryRow: View {
    let text: String

    var body: some View {
        HStack {
            Spacer(minLength: 48)

            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(VitoraTheme.ColorToken.strongText)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 232 / 255, green: 251 / 255, blue: 218 / 255).opacity(0.88),
                                    Color.white.opacity(0.72),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.78), lineWidth: 0.7))
                )
        }
    }
}

private struct OnboardingStepContinueButton: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "arrow.right")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(isDisabled ? VitoraTheme.ColorToken.tertiaryText : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(isDisabled ? Color.white.opacity(0.42) : VitoraTheme.ColorToken.actionPrimaryDeep)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.62 : 1)
    }
}

private struct OnboardingReadySummaryCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(VitoraTheme.ColorToken.actionPrimaryDeep)
                .frame(width: 34, height: 34)
                .background(VitoraTheme.ColorToken.actionPrimarySoft.opacity(0.70), in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("可以开始了")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(VitoraTheme.ColorToken.strongText)
                Text("Vitora 已有第一天需要的上下文，后面还可以随时补充。")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(VitoraTheme.ColorToken.secondaryText)
                    .lineSpacing(3)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.68))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.82), lineWidth: 0.8))
        )
    }
}

private struct ChatChoicePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .black))
                }
                Text(title)
                    .font(.system(size: 14, weight: .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(isSelected ? VitoraTheme.ColorToken.strongText : VitoraTheme.ColorToken.secondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.88) : Color.white.opacity(0.48))
                    .shadow(color: isSelected ? VitoraTheme.ColorToken.paperLiftShadow.opacity(0.12) : .clear, radius: 10, x: 0, y: 5)
            )
            .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0.86 : 0.48), lineWidth: 0.7))
        }
        .buttonStyle(.plain)
    }
}

private struct DeviceBindingButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(isSelected ? .white : VitoraTheme.ColorToken.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(isSelected ? VitoraTheme.ColorToken.strongText : Color.white.opacity(0.62))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 0.7)
                )
        }
        .buttonStyle(.plain)
    }
}
