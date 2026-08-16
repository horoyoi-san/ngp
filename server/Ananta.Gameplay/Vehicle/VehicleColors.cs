using System;
using System.Collections.Generic;

namespace AnantaTestGameServer
{
    /// <summary>
    /// Complete vehicle color palette (0-427) with categories and hex values.
    /// ID 0 = Default color (vehicle-specific). IDs > 427 fallback to 0.
    /// Organized by finish type: Gloss, Matte, Metallic, Pearl, Livery, etc.
    /// </summary>
    public static class VehicleColors
    {
        /// <summary>Maximum valid color ID (0-427). IDs above this fallback to 0 (vehicle default).</summary>
        public const uint MaxColorId = 427;

        public enum ColorCategory
        {
            Gloss,
            MatteWrap,
            MatteMetallic,
            Metallic,
            Pearl,
            Livery,
            Wrap,
            Special
        }

        public class VehicleColorInfo
        {
            public uint Id { get; }
            public string Name { get; }
            public ColorCategory Category { get; }
            public string Hex { get; }

            public VehicleColorInfo(uint id, string name, ColorCategory category, string hex)
            {
                Id = id;
                Name = name;
                Category = category;
                Hex = hex;
            }
        }

        private static readonly Dictionary<uint, VehicleColorInfo> _colors = new();
        private static readonly Dictionary<ColorCategory, List<uint>> _byCategory = new();
        private static readonly Random _rng = new();

        static VehicleColors()
        {
            foreach (ColorCategory cat in Enum.GetValues<ColorCategory>())
                _byCategory[cat] = new List<uint>();

            // ========== DEFAULT ==========
            Add(0, "Default (Vehicle-Specific)", ColorCategory.Special, "#888888");

            // ========== GLOSS (1-18) ==========
            Add(1, "Dark Gray Gloss", ColorCategory.Gloss, "#4a4a4a");
            Add(2, "Light Gray Gloss", ColorCategory.Gloss, "#8c8c8c");
            Add(3, "White Gloss", ColorCategory.Gloss, "#f0f0f0");
            Add(4, "Peach Soft Gloss", ColorCategory.Gloss, "#ffd5c2");
            Add(5, "Red (Pink) Gloss", ColorCategory.Gloss, "#e8637a");
            Add(6, "Orange Gloss", ColorCategory.Gloss, "#f0943a");
            Add(7, "Orange (Red) Gloss", ColorCategory.Gloss, "#e06030");
            Add(8, "Beige Gloss", ColorCategory.Gloss, "#d4c4a0");
            Add(9, "Lamborghini Yellow Gloss", ColorCategory.Gloss, "#f5d000");
            Add(10, "Pale Lime (Yellow) Gloss", ColorCategory.Gloss, "#d8e840");
            Add(11, "Pale Lime Gloss", ColorCategory.Gloss, "#c8e048");
            Add(12, "Pale Green Gloss", ColorCategory.Gloss, "#90d090");
            Add(13, "Light Blue Gloss", ColorCategory.Gloss, "#80c0e8");
            Add(14, "Light Blue Gloss 2", ColorCategory.Gloss, "#70b8e0");
            Add(15, "Pale Purple Gloss", ColorCategory.Gloss, "#c8a0d8");
            Add(16, "Fuchsia Pink Gloss", ColorCategory.Gloss, "#e060a0");
            Add(17, "Light Gray (White) Gloss", ColorCategory.Gloss, "#d8d8d8");
            Add(18, "Pale Light Blue Gloss", ColorCategory.Gloss, "#a8d8f0");

            // ========== MATTE WRAP (19-32) ==========
            Add(19, "Light Gray Metallic Matte", ColorCategory.MatteWrap, "#b0b0b0");
            Add(20, "Light Gray Matte", ColorCategory.MatteWrap, "#a0a0a0");
            Add(21, "Dark Gray Metallic Matte", ColorCategory.MatteWrap, "#606060");
            Add(22, "Dark Red Metallic Matte", ColorCategory.MatteWrap, "#8b2020");
            Add(23, "Dark Red Brown Metallic Matte", ColorCategory.MatteWrap, "#6b3030");
            Add(24, "Copper Matte", ColorCategory.MatteWrap, "#b87333");
            Add(25, "Bronze Matte", ColorCategory.MatteWrap, "#a08040");
            Add(26, "Dark Green Metallic Matte", ColorCategory.MatteWrap, "#2d5a27");
            Add(27, "Pale Green Matte", ColorCategory.MatteWrap, "#7dba6a");
            Add(28, "Cyan Metallic Matte", ColorCategory.MatteWrap, "#40a0a0");
            Add(29, "Purple Dark Blue Metallic Matte", ColorCategory.MatteWrap, "#3a3a6a");
            Add(30, "Black Matte", ColorCategory.MatteWrap, "#1a1a1a");
            Add(31, "Brown Metallic Matte", ColorCategory.MatteWrap, "#6a4a30");
            Add(32, "Gold Matte", ColorCategory.MatteWrap, "#c8a830");

            // ========== GLOSS (33-56) ==========
            Add(33, "Dark Gray Gloss 2", ColorCategory.Gloss, "#505050");
            Add(34, "Blue-ish White Gloss", ColorCategory.Gloss, "#e0e8f0");
            Add(35, "Yellow-ish White Gloss", ColorCategory.Gloss, "#f0ece0");
            Add(36, "White Gloss 2", ColorCategory.Gloss, "#f8f8f8");
            Add(37, "Red (Orange) Gloss", ColorCategory.Gloss, "#e85040");
            Add(38, "Red (Formula) Gloss", ColorCategory.Gloss, "#e02020");
            Add(39, "Orange (Yellow) Gloss", ColorCategory.Gloss, "#f0a020");
            Add(40, "Orange Gloss 2", ColorCategory.Gloss, "#e88030");
            Add(41, "Lamborghini Yellow Gloss 2", ColorCategory.Gloss, "#f0c800");
            Add(42, "Racing Yellow Gloss", ColorCategory.Gloss, "#f0d818");
            Add(43, "Pale Green Gloss 2", ColorCategory.Gloss, "#a0d870");
            Add(44, "Green Gloss", ColorCategory.Gloss, "#40a840");
            Add(45, "Dark Mint Gloss", ColorCategory.Gloss, "#308868");
            Add(46, "Porsche Riviera Blue Gloss", ColorCategory.Gloss, "#3878c0");
            Add(47, "Pale Light Blue Gloss 2", ColorCategory.Gloss, "#90c8e8");
            Add(48, "Dark Blue Gloss", ColorCategory.Gloss, "#204080");
            Add(49, "Light Purple Gloss", ColorCategory.Gloss, "#a080c0");
            Add(50, "Light Magenta Gloss", ColorCategory.Gloss, "#c070b0");
            Add(51, "Pink Gloss", ColorCategory.Gloss, "#e880a0");
            Add(52, "Burgundy Gloss", ColorCategory.Gloss, "#802040");
            Add(53, "Toxic Pink Gloss", ColorCategory.Gloss, "#d04080");
            Add(54, "Beige Gloss 2", ColorCategory.Gloss, "#c8b890");
            Add(55, "Cyan Gloss", ColorCategory.Gloss, "#40b0b0");
            Add(56, "Racing Yellow Gloss 2", ColorCategory.Gloss, "#e8d020");

            // ========== WRAP (57-63) ==========
            Add(57, "Pale Light Blue Wrap", ColorCategory.Wrap, "#90d0f0");
            Add(58, "Red (Orange) Wrap", ColorCategory.Wrap, "#e86040");
            Add(59, "Racing Yellow (Lime) Wrap", ColorCategory.Wrap, "#d0e020");
            Add(60, "Mint Wrap", ColorCategory.Wrap, "#60c8a0");
            Add(61, "Porsche Riviera Blue Wrap", ColorCategory.Wrap, "#4080c8");
            Add(62, "Purple Wrap", ColorCategory.Wrap, "#9040b0");
            Add(63, "Toxic Pink Wrap", ColorCategory.Wrap, "#d04888");

            // ========== GLOSS (64-73, 76) ==========
            Add(64, "Silver Metallic (Broken Livery) Gloss", ColorCategory.Gloss, "#b8b8b8");
            Add(65, "Gray Gloss", ColorCategory.Gloss, "#808080");
            Add(66, "Gray Lighter Gloss", ColorCategory.Gloss, "#989898");
            Add(67, "Olive Gloss", ColorCategory.Gloss, "#808040");
            Add(68, "Sand Gloss", ColorCategory.Gloss, "#c8b080");
            Add(69, "Silver Metallic Gloss", ColorCategory.Gloss, "#c0c0c0");
            Add(70, "Black Gloss", ColorCategory.Gloss, "#202020");
            Add(71, "Red Orange Pearl Gloss", ColorCategory.Gloss, "#d84030");
            Add(72, "White Gloss 3", ColorCategory.Gloss, "#f0f0f0");
            Add(73, "Lemon Gloss", ColorCategory.Gloss, "#e8e040");
            Add(76, "Jaguar Dark Green Gloss", ColorCategory.Gloss, "#1a4020");

            // ========== LIVERY (74-79) ==========
            Add(74, "White LightBlue Livery", ColorCategory.Livery, "#e0e8f0");
            Add(75, "White Golden Livery", ColorCategory.Livery, "#f0e8d0");
            Add(77, "White Lime Livery", ColorCategory.Livery, "#e0f0d0");
            Add(78, "Red Yellow-White Livery", ColorCategory.Livery, "#e84030");
            Add(79, "Black Pink Livery", ColorCategory.Livery, "#301020");

            // ========== MATTE METALLIC (80-193) ==========
            // Red gradient (80-85)
            Add(80, "Matte Red Dark", ColorCategory.MatteMetallic, "#501010");
            Add(81, "Matte Red 1", ColorCategory.MatteMetallic, "#681818");
            Add(82, "Matte Red 2", ColorCategory.MatteMetallic, "#802020");
            Add(83, "Matte Red 3", ColorCategory.MatteMetallic, "#983030");
            Add(84, "Matte Red 4", ColorCategory.MatteMetallic, "#b04040");
            Add(85, "Matte Red Pale", ColorCategory.MatteMetallic, "#c85050");

            // Orange gradient (86-91)
            Add(86, "Matte Orange Dark", ColorCategory.MatteMetallic, "#502008");
            Add(87, "Matte Orange 1", ColorCategory.MatteMetallic, "#683010");
            Add(88, "Matte Orange 2", ColorCategory.MatteMetallic, "#804018");
            Add(89, "Matte Orange 3", ColorCategory.MatteMetallic, "#985020");
            Add(90, "Matte Orange 4", ColorCategory.MatteMetallic, "#b06028");
            Add(91, "Matte Orange Pale", ColorCategory.MatteMetallic, "#c87030");

            // Golden Yellow gradient (92-97)
            Add(92, "Matte Golden Yellow Dark", ColorCategory.MatteMetallic, "#504008");
            Add(93, "Matte Golden Yellow 1", ColorCategory.MatteMetallic, "#685010");
            Add(94, "Matte Golden Yellow 2", ColorCategory.MatteMetallic, "#806018");
            Add(95, "Matte Golden Yellow 3", ColorCategory.MatteMetallic, "#987020");
            Add(96, "Matte Golden Yellow 4", ColorCategory.MatteMetallic, "#b08028");
            Add(97, "Matte Golden Yellow Pale", ColorCategory.MatteMetallic, "#c89030");

            // Lemon Yellow gradient (98-103)
            Add(98, "Matte Lemon Yellow Dark", ColorCategory.MatteMetallic, "#505008");
            Add(99, "Matte Lemon Yellow 1", ColorCategory.MatteMetallic, "#686010");
            Add(100, "Matte Lemon Yellow 2", ColorCategory.MatteMetallic, "#807018");
            Add(101, "Matte Lemon Yellow 3", ColorCategory.MatteMetallic, "#988020");
            Add(102, "Matte Lemon Yellow 4", ColorCategory.MatteMetallic, "#b09028");
            Add(103, "Matte Lemon Yellow Pale", ColorCategory.MatteMetallic, "#c8a030");

            // Sheen Green gradient (104-109)
            Add(104, "Matte Sheen Green Dark", ColorCategory.MatteMetallic, "#104010");
            Add(105, "Matte Sheen Green 1", ColorCategory.MatteMetallic, "#185818");
            Add(106, "Matte Sheen Green 2", ColorCategory.MatteMetallic, "#207020");
            Add(107, "Matte Sheen Green 3", ColorCategory.MatteMetallic, "#288828");
            Add(108, "Matte Sheen Green 4", ColorCategory.MatteMetallic, "#30a030");
            Add(109, "Matte Sheen Green Pale", ColorCategory.MatteMetallic, "#38b838");

            // Lime Green gradient (110-115)
            Add(110, "Matte Lime Green Dark", ColorCategory.MatteMetallic, "#205010");
            Add(111, "Matte Lime Green 1", ColorCategory.MatteMetallic, "#306818");
            Add(112, "Matte Lime Green 2", ColorCategory.MatteMetallic, "#408020");
            Add(113, "Matte Lime Green 3", ColorCategory.MatteMetallic, "#509828");
            Add(114, "Matte Lime Green 4", ColorCategory.MatteMetallic, "#60b030");
            Add(115, "Matte Lime Green Pale", ColorCategory.MatteMetallic, "#70c838");

            // Forest Green gradient (116-121)
            Add(116, "Matte Forest Green Dark", ColorCategory.MatteMetallic, "#103010");
            Add(117, "Matte Forest Green 1", ColorCategory.MatteMetallic, "#184818");
            Add(118, "Matte Forest Green 2", ColorCategory.MatteMetallic, "#206020");
            Add(119, "Matte Forest Green 3", ColorCategory.MatteMetallic, "#287828");
            Add(120, "Matte Forest Green 4", ColorCategory.MatteMetallic, "#309030");
            Add(121, "Matte Forest Green Pale", ColorCategory.MatteMetallic, "#38a838");

            // Emerald Green gradient (122-127)
            Add(122, "Matte Emerald Green Dark", ColorCategory.MatteMetallic, "#104830");
            Add(123, "Matte Emerald Green 1", ColorCategory.MatteMetallic, "#186040");
            Add(124, "Matte Emerald Green 2", ColorCategory.MatteMetallic, "#207850");
            Add(125, "Matte Emerald Green 3", ColorCategory.MatteMetallic, "#289060");
            Add(126, "Matte Emerald Green 4", ColorCategory.MatteMetallic, "#30a870");
            Add(127, "Matte Emerald Green Pale", ColorCategory.MatteMetallic, "#38c080");

            // Mint Green gradient (128-133)
            Add(128, "Matte Mint Green Dark", ColorCategory.MatteMetallic, "#105040");
            Add(129, "Matte Mint Green 1", ColorCategory.MatteMetallic, "#186850");
            Add(130, "Matte Mint Green 2", ColorCategory.MatteMetallic, "#208060");
            Add(131, "Matte Mint Green 3", ColorCategory.MatteMetallic, "#289870");
            Add(132, "Matte Mint Green 4", ColorCategory.MatteMetallic, "#30b080");
            Add(133, "Matte Mint Green Pale", ColorCategory.MatteMetallic, "#38c890");

            // Cyan gradient (134-139)
            Add(134, "Matte Cyan Dark", ColorCategory.MatteMetallic, "#104850");
            Add(135, "Matte Cyan 1", ColorCategory.MatteMetallic, "#186068");
            Add(136, "Matte Cyan 2", ColorCategory.MatteMetallic, "#207880");
            Add(137, "Matte Cyan 3", ColorCategory.MatteMetallic, "#289098");
            Add(138, "Matte Cyan 4", ColorCategory.MatteMetallic, "#30a8b0");
            Add(139, "Matte Cyan Pale", ColorCategory.MatteMetallic, "#38c0c8");

            // Light Blue gradient (140-145)
            Add(140, "Matte Light Blue Dark", ColorCategory.MatteMetallic, "#104058");
            Add(141, "Matte Light Blue 1", ColorCategory.MatteMetallic, "#185870");
            Add(142, "Matte Light Blue 2", ColorCategory.MatteMetallic, "#207088");
            Add(143, "Matte Light Blue 3", ColorCategory.MatteMetallic, "#2888a0");
            Add(144, "Matte Light Blue 4", ColorCategory.MatteMetallic, "#30a0b8");
            Add(145, "Matte Light Blue Pale", ColorCategory.MatteMetallic, "#38b8d0");

            // Blue gradient (146-151)
            Add(146, "Matte Blue Dark", ColorCategory.MatteMetallic, "#102050");
            Add(147, "Matte Blue 1", ColorCategory.MatteMetallic, "#183068");
            Add(148, "Matte Blue 2", ColorCategory.MatteMetallic, "#204080");
            Add(149, "Matte Blue 3", ColorCategory.MatteMetallic, "#285098");
            Add(150, "Matte Blue 4", ColorCategory.MatteMetallic, "#3060b0");
            Add(151, "Matte Blue Pale", ColorCategory.MatteMetallic, "#3870c8");

            // Navy Blue gradient (152-157)
            Add(152, "Matte Navy Blue Dark", ColorCategory.MatteMetallic, "#101840");
            Add(153, "Matte Navy Blue 1", ColorCategory.MatteMetallic, "#182050");
            Add(154, "Matte Navy Blue 2", ColorCategory.MatteMetallic, "#202860");
            Add(155, "Matte Navy Blue 3", ColorCategory.MatteMetallic, "#283070");
            Add(156, "Matte Navy Blue 4", ColorCategory.MatteMetallic, "#303880");
            Add(157, "Matte Navy Blue Pale", ColorCategory.MatteMetallic, "#384090");

            // Indigo gradient (158-163)
            Add(158, "Matte Indigo Dark", ColorCategory.MatteMetallic, "#201040");
            Add(159, "Matte Indigo 1", ColorCategory.MatteMetallic, "#301858");
            Add(160, "Matte Indigo 2", ColorCategory.MatteMetallic, "#402070");
            Add(161, "Matte Indigo 3", ColorCategory.MatteMetallic, "#502888");
            Add(162, "Matte Indigo 4", ColorCategory.MatteMetallic, "#6030a0");
            Add(163, "Matte Indigo Pale", ColorCategory.MatteMetallic, "#7038b8");

            // Violet gradient (164-169)
            Add(164, "Matte Violet Dark", ColorCategory.MatteMetallic, "#301050");
            Add(165, "Matte Violet 1", ColorCategory.MatteMetallic, "#401868");
            Add(166, "Matte Violet 2", ColorCategory.MatteMetallic, "#502080");
            Add(167, "Matte Violet 3", ColorCategory.MatteMetallic, "#602898");
            Add(168, "Matte Violet 4", ColorCategory.MatteMetallic, "#7030b0");
            Add(169, "Matte Violet Pale", ColorCategory.MatteMetallic, "#8038c8");

            // Purple gradient (170-175)
            Add(170, "Matte Purple Dark", ColorCategory.MatteMetallic, "#381050");
            Add(171, "Matte Purple 1", ColorCategory.MatteMetallic, "#481868");
            Add(172, "Matte Purple 2", ColorCategory.MatteMetallic, "#582080");
            Add(173, "Matte Purple 3", ColorCategory.MatteMetallic, "#682898");
            Add(174, "Matte Purple 4", ColorCategory.MatteMetallic, "#7830b0");
            Add(175, "Matte Purple Pale", ColorCategory.MatteMetallic, "#8838c8");

            // Magenta gradient (176-181)
            Add(176, "Matte Magenta Dark", ColorCategory.MatteMetallic, "#401040");
            Add(177, "Matte Magenta 1", ColorCategory.MatteMetallic, "#581858");
            Add(178, "Matte Magenta 2", ColorCategory.MatteMetallic, "#702070");
            Add(179, "Matte Magenta 3", ColorCategory.MatteMetallic, "#882888");
            Add(180, "Matte Magenta 4", ColorCategory.MatteMetallic, "#a030a0");
            Add(181, "Matte Magenta Pale", ColorCategory.MatteMetallic, "#b838b8");

            // Pink gradient (182-187)
            Add(182, "Matte Pink Dark", ColorCategory.MatteMetallic, "#501038");
            Add(183, "Matte Pink 1", ColorCategory.MatteMetallic, "#681848");
            Add(184, "Matte Pink 2", ColorCategory.MatteMetallic, "#802058");
            Add(185, "Matte Pink 3", ColorCategory.MatteMetallic, "#982868");
            Add(186, "Matte Pink 4", ColorCategory.MatteMetallic, "#b03078");
            Add(187, "Matte Pink Pale", ColorCategory.MatteMetallic, "#c83888");

            // Black to White Grayscale (188-193)
            Add(188, "Matte Grayscale Black", ColorCategory.MatteMetallic, "#101010");
            Add(189, "Matte Grayscale Dark", ColorCategory.MatteMetallic, "#303030");
            Add(190, "Matte Grayscale 1", ColorCategory.MatteMetallic, "#505050");
            Add(191, "Matte Grayscale 2", ColorCategory.MatteMetallic, "#707070");
            Add(192, "Matte Grayscale 3", ColorCategory.MatteMetallic, "#909090");
            Add(193, "Matte Grayscale Pale", ColorCategory.MatteMetallic, "#b0b0b0");

            // ========== METALLIC (194-307) ==========
            // Red gradient (194-199)
            Add(194, "Metallic Red Dark", ColorCategory.Metallic, "#601010");
            Add(195, "Metallic Red 1", ColorCategory.Metallic, "#781818");
            Add(196, "Metallic Red 2", ColorCategory.Metallic, "#902020");
            Add(197, "Metallic Red 3", ColorCategory.Metallic, "#a83030");
            Add(198, "Metallic Red 4", ColorCategory.Metallic, "#c04040");
            Add(199, "Metallic Red Pale", ColorCategory.Metallic, "#d85050");

            // Orange gradient (200-205)
            Add(200, "Metallic Orange Dark", ColorCategory.Metallic, "#602808");
            Add(201, "Metallic Orange 1", ColorCategory.Metallic, "#783810");
            Add(202, "Metallic Orange 2", ColorCategory.Metallic, "#904818");
            Add(203, "Metallic Orange 3", ColorCategory.Metallic, "#a85820");
            Add(204, "Metallic Orange 4", ColorCategory.Metallic, "#c06828");
            Add(205, "Metallic Orange Pale", ColorCategory.Metallic, "#d87830");

            // Golden Yellow gradient (206-211)
            Add(206, "Metallic Golden Yellow Dark", ColorCategory.Metallic, "#604808");
            Add(207, "Metallic Golden Yellow 1", ColorCategory.Metallic, "#785810");
            Add(208, "Metallic Golden Yellow 2", ColorCategory.Metallic, "#906818");
            Add(209, "Metallic Golden Yellow 3", ColorCategory.Metallic, "#a87820");
            Add(210, "Metallic Golden Yellow 4", ColorCategory.Metallic, "#c08828");
            Add(211, "Metallic Golden Yellow Pale", ColorCategory.Metallic, "#d89830");

            // Lemon Yellow gradient (212-217)
            Add(212, "Metallic Lemon Yellow Dark", ColorCategory.Metallic, "#605808");
            Add(213, "Metallic Lemon Yellow 1", ColorCategory.Metallic, "#786810");
            Add(214, "Metallic Lemon Yellow 2", ColorCategory.Metallic, "#907818");
            Add(215, "Metallic Lemon Yellow 3", ColorCategory.Metallic, "#a88820");
            Add(216, "Metallic Lemon Yellow 4", ColorCategory.Metallic, "#c09828");
            Add(217, "Metallic Lemon Yellow Pale", ColorCategory.Metallic, "#d8a830");

            // Sheen Green gradient (218-223)
            Add(218, "Metallic Sheen Green Dark", ColorCategory.Metallic, "#185018");
            Add(219, "Metallic Sheen Green 1", ColorCategory.Metallic, "#206820");
            Add(220, "Metallic Sheen Green 2", ColorCategory.Metallic, "#288028");
            Add(221, "Metallic Sheen Green 3", ColorCategory.Metallic, "#309830");
            Add(222, "Metallic Sheen Green 4", ColorCategory.Metallic, "#38b038");
            Add(223, "Metallic Sheen Green Pale", ColorCategory.Metallic, "#40c840");

            // Lime Green gradient (224-229)
            Add(224, "Metallic Lime Green Dark", ColorCategory.Metallic, "#286018");
            Add(225, "Metallic Lime Green 1", ColorCategory.Metallic, "#387820");
            Add(226, "Metallic Lime Green 2", ColorCategory.Metallic, "#489028");
            Add(227, "Metallic Lime Green 3", ColorCategory.Metallic, "#58a830");
            Add(228, "Metallic Lime Green 4", ColorCategory.Metallic, "#68c038");
            Add(229, "Metallic Lime Green Pale", ColorCategory.Metallic, "#78d840");

            // Forest Green gradient (230-235)
            Add(230, "Metallic Forest Green Dark", ColorCategory.Metallic, "#184018");
            Add(231, "Metallic Forest Green 1", ColorCategory.Metallic, "#205820");
            Add(232, "Metallic Forest Green 2", ColorCategory.Metallic, "#287028");
            Add(233, "Metallic Forest Green 3", ColorCategory.Metallic, "#308830");
            Add(234, "Metallic Forest Green 4", ColorCategory.Metallic, "#38a038");
            Add(235, "Metallic Forest Green Pale", ColorCategory.Metallic, "#40b840");

            // Emerald Green gradient (236-241)
            Add(236, "Metallic Emerald Green Dark", ColorCategory.Metallic, "#185838");
            Add(237, "Metallic Emerald Green 1", ColorCategory.Metallic, "#207048");
            Add(238, "Metallic Emerald Green 2", ColorCategory.Metallic, "#288858");
            Add(239, "Metallic Emerald Green 3", ColorCategory.Metallic, "#30a068");
            Add(240, "Metallic Emerald Green 4", ColorCategory.Metallic, "#38b878");
            Add(241, "Metallic Emerald Green Pale", ColorCategory.Metallic, "#40d088");

            // Mint Green gradient (242-247)
            Add(242, "Metallic Mint Green Dark", ColorCategory.Metallic, "#186048");
            Add(243, "Metallic Mint Green 1", ColorCategory.Metallic, "#207858");
            Add(244, "Metallic Mint Green 2", ColorCategory.Metallic, "#289068");
            Add(245, "Metallic Mint Green 3", ColorCategory.Metallic, "#30a878");
            Add(246, "Metallic Mint Green 4", ColorCategory.Metallic, "#38c088");
            Add(247, "Metallic Mint Green Pale", ColorCategory.Metallic, "#40d898");

            // Cyan gradient (248-253)
            Add(248, "Metallic Cyan Dark", ColorCategory.Metallic, "#185860");
            Add(249, "Metallic Cyan 1", ColorCategory.Metallic, "#207078");
            Add(250, "Metallic Cyan 2", ColorCategory.Metallic, "#288890");
            Add(251, "Metallic Cyan 3", ColorCategory.Metallic, "#30a0a8");
            Add(252, "Metallic Cyan 4", ColorCategory.Metallic, "#38b8c0");
            Add(253, "Metallic Cyan Pale", ColorCategory.Metallic, "#40d0d8");

            // Light Blue gradient (254-259)
            Add(254, "Metallic Light Blue Dark", ColorCategory.Metallic, "#185068");
            Add(255, "Metallic Light Blue 1", ColorCategory.Metallic, "#206880");
            Add(256, "Metallic Light Blue 2", ColorCategory.Metallic, "#288098");
            Add(257, "Metallic Light Blue 3", ColorCategory.Metallic, "#3098b0");
            Add(258, "Metallic Light Blue 4", ColorCategory.Metallic, "#38b0c8");
            Add(259, "Metallic Light Blue Pale", ColorCategory.Metallic, "#40c8e0");

            // Blue gradient (260-265)
            Add(260, "Metallic Blue Dark", ColorCategory.Metallic, "#183060");
            Add(261, "Metallic Blue 1", ColorCategory.Metallic, "#204078");
            Add(262, "Metallic Blue 2", ColorCategory.Metallic, "#285090");
            Add(263, "Metallic Blue 3", ColorCategory.Metallic, "#3060a8");
            Add(264, "Metallic Blue 4", ColorCategory.Metallic, "#3870c0");
            Add(265, "Metallic Blue Pale", ColorCategory.Metallic, "#4080d8");

            // Navy Blue gradient (266-271)
            Add(266, "Metallic Navy Blue Dark", ColorCategory.Metallic, "#182048");
            Add(267, "Metallic Navy Blue 1", ColorCategory.Metallic, "#202858");
            Add(268, "Metallic Navy Blue 2", ColorCategory.Metallic, "#283068");
            Add(269, "Metallic Navy Blue 3", ColorCategory.Metallic, "#303878");
            Add(270, "Metallic Navy Blue 4", ColorCategory.Metallic, "#384088");
            Add(271, "Metallic Navy Blue Pale", ColorCategory.Metallic, "#404898");

            // Indigo gradient (272-277)
            Add(272, "Metallic Indigo Dark", ColorCategory.Metallic, "#281850");
            Add(273, "Metallic Indigo 1", ColorCategory.Metallic, "#382068");
            Add(274, "Metallic Indigo 2", ColorCategory.Metallic, "#482880");
            Add(275, "Metallic Indigo 3", ColorCategory.Metallic, "#583098");
            Add(276, "Metallic Indigo 4", ColorCategory.Metallic, "#6838b0");
            Add(277, "Metallic Indigo Pale", ColorCategory.Metallic, "#7840c8");

            // Violet gradient (278-283)
            Add(278, "Metallic Violet Dark", ColorCategory.Metallic, "#381860");
            Add(279, "Metallic Violet 1", ColorCategory.Metallic, "#482078");
            Add(280, "Metallic Violet 2", ColorCategory.Metallic, "#582890");
            Add(281, "Metallic Violet 3", ColorCategory.Metallic, "#6830a8");
            Add(282, "Metallic Violet 4", ColorCategory.Metallic, "#7838c0");
            Add(283, "Metallic Violet Pale", ColorCategory.Metallic, "#8840d8");

            // Purple gradient (284-289)
            Add(284, "Metallic Purple Dark", ColorCategory.Metallic, "#401860");
            Add(285, "Metallic Purple 1", ColorCategory.Metallic, "#502078");
            Add(286, "Metallic Purple 2", ColorCategory.Metallic, "#602890");
            Add(287, "Metallic Purple 3", ColorCategory.Metallic, "#7030a8");
            Add(288, "Metallic Purple 4", ColorCategory.Metallic, "#8038c0");
            Add(289, "Metallic Purple Pale", ColorCategory.Metallic, "#9040d8");

            // Magenta gradient (290-296) - Note: only 7 entries
            Add(290, "Metallic Magenta Dark", ColorCategory.Metallic, "#481850");
            Add(291, "Metallic Magenta 1", ColorCategory.Metallic, "#602068");
            Add(292, "Metallic Magenta 2", ColorCategory.Metallic, "#782880");
            Add(293, "Metallic Magenta 3", ColorCategory.Metallic, "#903098");
            Add(294, "Metallic Magenta 4", ColorCategory.Metallic, "#a838b0");
            Add(295, "Metallic Magenta 5", ColorCategory.Metallic, "#c040c8");
            Add(296, "Metallic Magenta Pale", ColorCategory.Metallic, "#d848e0");

            // Pink gradient (297-301) - Note: only 5 entries
            Add(297, "Metallic Pink Dark", ColorCategory.Metallic, "#601848");
            Add(298, "Metallic Pink 1", ColorCategory.Metallic, "#782060");
            Add(299, "Metallic Pink 2", ColorCategory.Metallic, "#902878");
            Add(300, "Metallic Pink 3", ColorCategory.Metallic, "#a83090");
            Add(301, "Metallic Pink Pale", ColorCategory.Metallic, "#c038a8");

            // Black to White Grayscale (302-307)
            Add(302, "Metallic Grayscale Black", ColorCategory.Metallic, "#181818");
            Add(303, "Metallic Grayscale Dark", ColorCategory.Metallic, "#383838");
            Add(304, "Metallic Grayscale 1", ColorCategory.Metallic, "#585858");
            Add(305, "Metallic Grayscale 2", ColorCategory.Metallic, "#787878");
            Add(306, "Metallic Grayscale 3", ColorCategory.Metallic, "#989898");
            Add(307, "Metallic Grayscale Pale", ColorCategory.Metallic, "#b8b8b8");

            // ========== PEARL (308-421) ==========
            // Red gradient (308-313)
            Add(308, "Pearl Red Dark", ColorCategory.Pearl, "#701818");
            Add(309, "Pearl Red 1", ColorCategory.Pearl, "#882020");
            Add(310, "Pearl Red 2", ColorCategory.Pearl, "#a02828");
            Add(311, "Pearl Red 3", ColorCategory.Pearl, "#b83030");
            Add(312, "Pearl Red 4", ColorCategory.Pearl, "#d03838");
            Add(313, "Pearl Red Pale", ColorCategory.Pearl, "#e84040");

            // Orange gradient (314-319)
            Add(314, "Pearl Orange Dark", ColorCategory.Pearl, "#703010");
            Add(315, "Pearl Orange 1", ColorCategory.Pearl, "#884018");
            Add(316, "Pearl Orange 2", ColorCategory.Pearl, "#a05020");
            Add(317, "Pearl Orange 3", ColorCategory.Pearl, "#b86028");
            Add(318, "Pearl Orange 4", ColorCategory.Pearl, "#d07030");
            Add(319, "Pearl Orange Pale", ColorCategory.Pearl, "#e88038");

            // Golden Yellow gradient (320-325)
            Add(320, "Pearl Golden Yellow Dark", ColorCategory.Pearl, "#705010");
            Add(321, "Pearl Golden Yellow 1", ColorCategory.Pearl, "#886018");
            Add(322, "Pearl Golden Yellow 2", ColorCategory.Pearl, "#a07020");
            Add(323, "Pearl Golden Yellow 3", ColorCategory.Pearl, "#b88028");
            Add(324, "Pearl Golden Yellow 4", ColorCategory.Pearl, "#d09030");
            Add(325, "Pearl Golden Yellow Pale", ColorCategory.Pearl, "#e8a038");

            // Lemon Yellow gradient (326-331)
            Add(326, "Pearl Lemon Yellow Dark", ColorCategory.Pearl, "#706010");
            Add(327, "Pearl Lemon Yellow 1", ColorCategory.Pearl, "#887018");
            Add(328, "Pearl Lemon Yellow 2", ColorCategory.Pearl, "#a08020");
            Add(329, "Pearl Lemon Yellow 3", ColorCategory.Pearl, "#b89028");
            Add(330, "Pearl Lemon Yellow 4", ColorCategory.Pearl, "#d0a030");
            Add(331, "Pearl Lemon Yellow Pale", ColorCategory.Pearl, "#e8b038");

            // Sheen Green gradient (332-337)
            Add(332, "Pearl Sheen Green Dark", ColorCategory.Pearl, "#206020");
            Add(333, "Pearl Sheen Green 1", ColorCategory.Pearl, "#287828");
            Add(334, "Pearl Sheen Green 2", ColorCategory.Pearl, "#309030");
            Add(335, "Pearl Sheen Green 3", ColorCategory.Pearl, "#38a838");
            Add(336, "Pearl Sheen Green 4", ColorCategory.Pearl, "#40c040");
            Add(337, "Pearl Sheen Green Pale", ColorCategory.Pearl, "#48d848");

            // Lime Green gradient (338-343)
            Add(338, "Pearl Lime Green Dark", ColorCategory.Pearl, "#307020");
            Add(339, "Pearl Lime Green 1", ColorCategory.Pearl, "#408828");
            Add(340, "Pearl Lime Green 2", ColorCategory.Pearl, "#50a030");
            Add(341, "Pearl Lime Green 3", ColorCategory.Pearl, "#60b838");
            Add(342, "Pearl Lime Green 4", ColorCategory.Pearl, "#70d040");
            Add(343, "Pearl Lime Green Pale", ColorCategory.Pearl, "#80e848");

            // Forest Green gradient (344-349)
            Add(344, "Pearl Forest Green Dark", ColorCategory.Pearl, "#205020");
            Add(345, "Pearl Forest Green 1", ColorCategory.Pearl, "#286828");
            Add(346, "Pearl Forest Green 2", ColorCategory.Pearl, "#308030");
            Add(347, "Pearl Forest Green 3", ColorCategory.Pearl, "#389838");
            Add(348, "Pearl Forest Green 4", ColorCategory.Pearl, "#40b040");
            Add(349, "Pearl Forest Green Pale", ColorCategory.Pearl, "#48c848");

            // Emerald Green gradient (350-355)
            Add(350, "Pearl Emerald Green Dark", ColorCategory.Pearl, "#206840");
            Add(351, "Pearl Emerald Green 1", ColorCategory.Pearl, "#288050");
            Add(352, "Pearl Emerald Green 2", ColorCategory.Pearl, "#309860");
            Add(353, "Pearl Emerald Green 3", ColorCategory.Pearl, "#38b070");
            Add(354, "Pearl Emerald Green 4", ColorCategory.Pearl, "#40c880");
            Add(355, "Pearl Emerald Green Pale", ColorCategory.Pearl, "#48e090");

            // Mint Green gradient (356-361)
            Add(356, "Pearl Mint Green Dark", ColorCategory.Pearl, "#207050");
            Add(357, "Pearl Mint Green 1", ColorCategory.Pearl, "#288860");
            Add(358, "Pearl Mint Green 2", ColorCategory.Pearl, "#30a070");
            Add(359, "Pearl Mint Green 3", ColorCategory.Pearl, "#38b880");
            Add(360, "Pearl Mint Green 4", ColorCategory.Pearl, "#40d090");
            Add(361, "Pearl Mint Green Pale", ColorCategory.Pearl, "#48e8a0");

            // Cyan gradient (362-367)
            Add(362, "Pearl Cyan Dark", ColorCategory.Pearl, "#206868");
            Add(363, "Pearl Cyan 1", ColorCategory.Pearl, "#288080");
            Add(364, "Pearl Cyan 2", ColorCategory.Pearl, "#309898");
            Add(365, "Pearl Cyan 3", ColorCategory.Pearl, "#38b0b0");
            Add(366, "Pearl Cyan 4", ColorCategory.Pearl, "#40c8c8");
            Add(367, "Pearl Cyan Pale", ColorCategory.Pearl, "#48e0e0");

            // Light Blue gradient (368-373)
            Add(368, "Pearl Light Blue Dark", ColorCategory.Pearl, "#205870");
            Add(369, "Pearl Light Blue 1", ColorCategory.Pearl, "#287088");
            Add(370, "Pearl Light Blue 2", ColorCategory.Pearl, "#3088a0");
            Add(371, "Pearl Light Blue 3", ColorCategory.Pearl, "#38a0b8");
            Add(372, "Pearl Light Blue 4", ColorCategory.Pearl, "#40b8d0");
            Add(373, "Pearl Light Blue Pale", ColorCategory.Pearl, "#48d0e8");

            // Blue gradient (374-379)
            Add(374, "Pearl Blue Dark", ColorCategory.Pearl, "#203868");
            Add(375, "Pearl Blue 1", ColorCategory.Pearl, "#284880");
            Add(376, "Pearl Blue 2", ColorCategory.Pearl, "#305898");
            Add(377, "Pearl Blue 3", ColorCategory.Pearl, "#3868b0");
            Add(378, "Pearl Blue 4", ColorCategory.Pearl, "#4078c8");
            Add(379, "Pearl Blue Pale", ColorCategory.Pearl, "#4888e0");

            // Navy Blue gradient (380-385)
            Add(380, "Pearl Navy Blue Dark", ColorCategory.Pearl, "#202850");
            Add(381, "Pearl Navy Blue 1", ColorCategory.Pearl, "#283060");
            Add(382, "Pearl Navy Blue 2", ColorCategory.Pearl, "#303870");
            Add(383, "Pearl Navy Blue 3", ColorCategory.Pearl, "#384080");
            Add(384, "Pearl Navy Blue 4", ColorCategory.Pearl, "#404890");
            Add(385, "Pearl Navy Blue Pale", ColorCategory.Pearl, "#4850a0");

            // Indigo gradient (386-391)
            Add(386, "Pearl Indigo Dark", ColorCategory.Pearl, "#302060");
            Add(387, "Pearl Indigo 1", ColorCategory.Pearl, "#402878");
            Add(388, "Pearl Indigo 2", ColorCategory.Pearl, "#503090");
            Add(389, "Pearl Indigo 3", ColorCategory.Pearl, "#6038a8");
            Add(390, "Pearl Indigo 4", ColorCategory.Pearl, "#7040c0");
            Add(391, "Pearl Indigo Pale", ColorCategory.Pearl, "#8048d8");

            // Violet gradient (392-397)
            Add(392, "Pearl Violet Dark", ColorCategory.Pearl, "#402068");
            Add(393, "Pearl Violet 1", ColorCategory.Pearl, "#502880");
            Add(394, "Pearl Violet 2", ColorCategory.Pearl, "#603098");
            Add(395, "Pearl Violet 3", ColorCategory.Pearl, "#7038b0");
            Add(396, "Pearl Violet 4", ColorCategory.Pearl, "#8040c8");
            Add(397, "Pearl Violet Pale", ColorCategory.Pearl, "#9048e0");

            // Purple gradient (398-403)
            Add(398, "Pearl Purple Dark", ColorCategory.Pearl, "#482068");
            Add(399, "Pearl Purple 1", ColorCategory.Pearl, "#582880");
            Add(400, "Pearl Purple 2", ColorCategory.Pearl, "#683098");
            Add(401, "Pearl Purple 3", ColorCategory.Pearl, "#7838b0");
            Add(402, "Pearl Purple 4", ColorCategory.Pearl, "#8840c8");
            Add(403, "Pearl Purple Pale", ColorCategory.Pearl, "#9848e0");

            // Magenta gradient (404-409)
            Add(404, "Pearl Magenta Dark", ColorCategory.Pearl, "#502058");
            Add(405, "Pearl Magenta 1", ColorCategory.Pearl, "#682870");
            Add(406, "Pearl Magenta 2", ColorCategory.Pearl, "#803088");
            Add(407, "Pearl Magenta 3", ColorCategory.Pearl, "#9838a0");
            Add(408, "Pearl Magenta 4", ColorCategory.Pearl, "#b040b8");
            Add(409, "Pearl Magenta Pale", ColorCategory.Pearl, "#c848d0");

            // Pink gradient (410-415)
            Add(410, "Pearl Pink Dark", ColorCategory.Pearl, "#602050");
            Add(411, "Pearl Pink 1", ColorCategory.Pearl, "#782868");
            Add(412, "Pearl Pink 2", ColorCategory.Pearl, "#903080");
            Add(413, "Pearl Pink 3", ColorCategory.Pearl, "#a83898");
            Add(414, "Pearl Pink 4", ColorCategory.Pearl, "#c040b0");
            Add(415, "Pearl Pink Pale", ColorCategory.Pearl, "#d848c8");

            // Black to White Grayscale (416-421)
            Add(416, "Pearl Grayscale Black", ColorCategory.Pearl, "#202020");
            Add(417, "Pearl Grayscale Dark", ColorCategory.Pearl, "#404040");
            Add(418, "Pearl Grayscale 1", ColorCategory.Pearl, "#606060");
            Add(419, "Pearl Grayscale 2", ColorCategory.Pearl, "#808080");
            Add(420, "Pearl Grayscale 3", ColorCategory.Pearl, "#a0a0a0");
            Add(421, "Pearl Grayscale Pale", ColorCategory.Pearl, "#c0c0c0");

            // ========== LIVERY (422-427) ==========
            Add(422, "Cat Express Silver (Reifence Lingtu)", ColorCategory.Livery, "#b0b0b0");
            Add(423, "Cat Express Silver (Korou Cruze)", ColorCategory.Livery, "#b8b8b8");
            Add(424, "Red Dirty (Kazama Wasteland)", ColorCategory.Livery, "#8b3020");
            Add(425, "Vault Security (Kazama Highland)", ColorCategory.Livery, "#4a6040");
            Add(426, "Vault Security (Korou Cruze)", ColorCategory.Livery, "#506848");
            Add(427, "Cat Express Blue", ColorCategory.Livery, "#305888");
        }

        private static void Add(uint id, string name, ColorCategory category, string hex)
        {
            var info = new VehicleColorInfo(id, name, category, hex);
            _colors[id] = info;
            _byCategory[category].Add(id);
        }

        /// <summary>Normalize color ID: IDs > MaxColorId fallback to 0 (vehicle default).</summary>
        public static uint Normalize(uint id)
        {
            return id > MaxColorId ? 0 : id;
        }

        /// <summary>Get color info by ID. IDs > MaxColorId return the default (0) info.</summary>
        public static VehicleColorInfo GetColor(uint id)
        {
            uint key = Normalize(id);
            return _colors.TryGetValue(key, out var info) ? info : _colors[0];
        }

        /// <summary>Get hex string for a color ID. IDs > MaxColorId return the default hex.</summary>
        public static string GetHex(uint id)
        {
            uint key = Normalize(id);
            return _colors.TryGetValue(key, out var info) ? info.Hex : "#888888";
        }

        /// <summary>Get all color IDs in a category.</summary>
        public static IReadOnlyList<uint> GetByCategory(ColorCategory category)
        {
            return _byCategory.TryGetValue(category, out var list) ? list.AsReadOnly() : Array.Empty<uint>();
        }

        /// <summary>Get all defined color IDs.</summary>
        public static IReadOnlyCollection<uint> AllIds => _colors.Keys;

        /// <summary>Get total number of defined colors.</summary>
        public static int Count => _colors.Count;

        /// <summary>Check if a color ID is valid (0-427). IDs > 427 are normalized to 0.</summary>
        public static bool IsValid(uint id) => _colors.ContainsKey(Normalize(id));

        /// <summary>Get a random color ID from all available colors.</summary>
        public static uint RandomColor() => _colors.Keys.ElementAt(_rng.Next(_colors.Count));

        /// <summary>Get a random color ID from a specific category.</summary>
        public static uint RandomColor(ColorCategory category)
        {
            if (!_byCategory.TryGetValue(category, out var list) || list.Count == 0)
                return 0;
            return list[_rng.Next(list.Count)];
        }

        /// <summary>Get a random common color (Gloss, Matte, or Metallic).</summary>
        public static uint RandomCommonColor()
        {
            var categories = new[] { ColorCategory.Gloss, ColorCategory.MatteWrap, ColorCategory.MatteMetallic, ColorCategory.Metallic };
            return RandomColor(categories[_rng.Next(categories.Length)]);
        }

        /// <summary>Map legacy color IDs and normalize out-of-range IDs.</summary>
        public static uint MapLegacyColor(uint colorId)
        {
            uint mapped = colorId switch
            {
                352 => 232,
                382 => 262,
                _ => colorId,
            };
            return Normalize(mapped);
        }

        /// <summary>Get a random color from a vehicle's available color list.
        /// If the list is empty or null, returns a random common color.</summary>
        public static uint GetRandomColorForVehicle(List<uint> vehicleColors)
        {
            if (vehicleColors != null && vehicleColors.Count > 0)
            {
                uint chosen = vehicleColors[_rng.Next(vehicleColors.Count)];
                return Normalize(chosen);
            }
            return RandomCommonColor();
        }

        /// <summary>Get the first valid color from a vehicle's color list.
        /// If the list is empty or null, returns 0 (vehicle default).</summary>
        public static uint GetDefaultColorForVehicle(List<uint> vehicleColors)
        {
            if (vehicleColors != null && vehicleColors.Count > 0)
            {
                return Normalize(vehicleColors[0]);
            }
            return 0;
        }

        /// <summary>Get all colors as a dictionary for JSON serialization.</summary>
        public static Dictionary<uint, object> GetAllForJson()
        {
            var result = new Dictionary<uint, object>();
            foreach (var kvp in _colors)
            {
                result[kvp.Key] = new
                {
                    name = kvp.Value.Name,
                    category = kvp.Value.Category.ToString(),
                    hex = kvp.Value.Hex
                };
            }
            return result;
        }
    }
}
